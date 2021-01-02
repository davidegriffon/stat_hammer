defmodule StatHammer.Phases.Reroll do
  alias StatHammer.Math.Fraction
  alias StatHammer.Math.Probability
  alias StatHammer.Structs.Simulation
  alias StatHammer.Structs.SecondChance
  alias StatHammer.Structs.Bucket
  alias StatHammer.Structs.BucketModifier
  alias StatHammer.Structs.SimulationResult
  alias StatHammer.Phases.HitRoll

  def probabiliy_to_roll_one_given_a_miss(skill) do
    Fraction.new(1, skill - 1)
  end

  @spec second_chances(non_neg_integer(), non_neg_integer(), :reroll_all | :reroll_ones | :reroll_none) :: list(SecondChance.t())
  def second_chances(_skill, _number_of_fails, :reroll_none) do
    []
  end
  def second_chances(_skill, 0, _type) do
    []
  end
  def second_chances(2, number_of_fails, :reroll_ones) do
    [%SecondChance{number_of_dice: number_of_fails, probability: Fraction.new(1)}]
  end
  def second_chances(_skill, number_of_fails, :reroll_all) do
    [%SecondChance{number_of_dice: number_of_fails, probability: Fraction.new(1)}]
  end
  def second_chances(skill, number_of_fails, :reroll_ones) do
    probability_to_roll_one = probabiliy_to_roll_one_given_a_miss(skill)
    # note: contains also 0 even if not necessary, this is useful for test because the sum of this list must be 1
    second_chances = Enum.map(
      0..number_of_fails, # see above
      fn number_of_ones ->
        %SecondChance{
          number_of_dice: number_of_ones,
          probability:
            Probability.probabilty_to_success_n_times(
              probability_to_roll_one, number_of_fails, number_of_ones
            )
        }
      end
    )
    second_chances
  end

  def modifiers_of_second_chance(
    second_chance = %SecondChance{},
    skill,
    original_bucket,
    phase
  ) do
    histogram =
      case phase do
        :hit_phase ->
          HitRoll.histogram(
            skill,
            second_chance.number_of_dice,
            second_chance.probability
          )
        :wound_phase ->
          nil
      end

    histogram
    |> Enum.filter(
      # we are not interested in bucket of 0 dice: it means no reroll
      fn bucket -> bucket.value > 0 end
    )
    |> Enum.map(
      # transform list of %Bucket{} in a list of %BucketModifier
      fn bucket -> %BucketModifier{
        type: :add,
        bucket_value: bucket.value + original_bucket.value,
        probability: bucket.probability,
      } end
    )
  end

  @spec chances_to_modifiers(list(SecondChance.t()), non_neg_integer(), Bucket.t()) :: list(BucketModifier.t())
  def chances_to_modifiers(
    chances, skill, original_bucket
  ) do
    # get rid of SecondChance with number_of_dice equals to 0
    Enum.filter(
      chances,
      fn second_chance -> second_chance.number_of_dice > 0 end
    )
    # transform every chance to modifiers
    |> Enum.map(
      fn second_chance ->
        modifiers_of_second_chance(
          second_chance, skill, original_bucket, :hit_phase
        )
      end
    )
    |> List.flatten()
    # multiply modifiers to the probability of the source bucket
    |> Enum.map(
      fn bm -> %BucketModifier{
        bm | probability: Fraction.multiply(bm.probability, original_bucket.probability)
      } end
    )
  end

  def append_subtraction_modifier([], _bucket) do
    []
  end
  def append_subtraction_modifier(add_modifiers, bucket) do
    cumulative_probability_of_add_modifiers =
      Enum.reduce(
        add_modifiers,
        Fraction.new(0),
        fn bm, acc -> Fraction.add(bm.probability, acc) end
      )
    subtraction_modifier =
      %BucketModifier{
        type: :subtraction,
        bucket_value: bucket.value,
        probability: cumulative_probability_of_add_modifiers
      }
    # append subtraction modifier for the source bucket
    [subtraction_modifier | add_modifiers]
  end

  def modifiers_of_bucket(
    bucket = %Bucket{},
    simulation = %Simulation{}
  ) do
    skill = simulation.attack.skill
    number_of_dice = simulation.attack.number_of_dice
    reroll_type = simulation.attack.hit_modifiers.reroll
    number_of_fails = number_of_dice - bucket.value

    second_chances(skill, number_of_fails, reroll_type)
    |> chances_to_modifiers(skill, bucket)
    |> append_subtraction_modifier(bucket)
    |> List.flatten()
  end

  @spec modifiers_of_simulation(Simulation.t()) :: Simulation.t()
  def modifiers_of_simulation(simulation = %Simulation{}) do
    modifiers =
      Enum.map(
        simulation.result.histogram,  # list of bucket
        fn bucket -> modifiers_of_bucket(bucket, simulation) end
      )
      |> List.flatten()

    meta = Map.put(
      simulation.meta,
      :hit_reroll_modifiers, modifiers
    )
    %Simulation{simulation | meta: meta}
  end

  def apply_modifier_to_bucket(
    bucket = %Bucket{value: bucket_value},
    modifier = %BucketModifier{bucket_value: bucket_value}
  ) do
    new_probability =
      case modifier.type do
        :add -> Fraction.add(bucket.probability, modifier.probability)
        :subtraction -> Fraction.subtraction(bucket.probability, modifier.probability)
      end
    %Bucket{
      value: bucket_value,
      probability: new_probability
    }
  end
  def apply_modifier_to_bucket(
    bucket = %Bucket{},
    _modifier = %BucketModifier{}
  ) do
    bucket
  end

  def apply_modifiers_to_bucket(
    bucket = %Bucket{}, bucket_modifiers
  ) do
    Enum.reduce(
      bucket_modifiers,
      bucket,
      fn modifier, bucket ->
        apply_modifier_to_bucket(bucket, modifier)
      end
    )
  end

  def apply_modifiers_to_simulation(simulation = %Simulation{}) do
    modifiers = simulation.meta.hit_reroll_modifiers
    histogram =
      Enum.map(
        simulation.result.histogram,
        fn bucket -> apply_modifiers_to_bucket(bucket, modifiers) end
      )
    result =
      %SimulationResult{
        histogram: histogram,
        previous_phase: :hit_reroll_phase,
      }
    %Simulation{simulation | result: result}
  end

  @spec apply(Simulation.t()) :: Simulation.t()
  def apply(simulation = %Simulation{}) do
    if simulation.attack.hit_modifiers.reroll == :reroll_none do
      simulation
    else
      simulation
      |> modifiers_of_simulation()
      |> apply_modifiers_to_simulation()
    end
  end

end
