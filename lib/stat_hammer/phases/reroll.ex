defmodule StatHammer.Phases.Reroll do
  alias StatHammer.Math.Fraction
  alias StatHammer.Math.Probability
  alias StatHammer.Math.Histogram
  alias StatHammer.Structs.Simulation
  alias StatHammer.Structs.SecondChance
  alias StatHammer.Structs.Bucket
  alias StatHammer.Structs.BucketModifier
  alias StatHammer.Structs.SimulationResult
  alias StatHammer.Phases.HitRoll
  alias StatHammer.Phases.WoundRoll

  def probability_to_roll_one_given_a_miss(skill) do
    Fraction.new(1, skill - 1)
  end

  @spec second_chances(
    Fraction.t(), non_neg_integer(), :reroll_all | :reroll_ones | :reroll_none
  ) :: list(SecondChance.t())
  def second_chances(_probability_to_roll_one, _number_of_fails, :reroll_none) do
    []
  end
  def second_chances(_probability_to_roll_one, 0, _type) do
    []
  end
  def second_chances(
    %Fraction{numerator: 1, denominator: 1}, number_of_fails, :reroll_ones
  ) do
    [%SecondChance{number_of_dice: number_of_fails, probability: Fraction.new(1)}]
  end
  def second_chances(_probability_to_roll_one, number_of_fails, :reroll_all) do
    [%SecondChance{number_of_dice: number_of_fails, probability: Fraction.new(1)}]
  end
  def second_chances(probability_to_roll_one, number_of_fails, :reroll_ones) do
    # note: this list contains also 0 `number_of_fails` even if not necessary
    #       this is useful for test because the sum of probabilities must be 1
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
    event_probability,
    original_bucket
  ) do
    Histogram.generate(
      event_probability,
      second_chance.number_of_dice,
      second_chance.probability
    )
    |> Enum.filter(
      # we are not interested in bucket of 0 dice: it means no reroll
      fn bucket -> bucket.value > 0 end
    )
    |> Enum.map(
      # transform list of %Bucket{} in a list of %BucketModifier
      fn bucket ->
        %BucketModifier{
          type: :add,
          bucket_value: bucket.value + original_bucket.value,
          probability: bucket.probability,
        }
      end
    )
  end

  @spec chances_to_modifiers(
    list(SecondChance.t()), Fraction.t(), Bucket.t()
  ) :: list(BucketModifier.t())
  def chances_to_modifiers(
    chances, event_probability, original_bucket
  ) do
    # get rid of SecondChance with number_of_dice equals to 0
    Enum.filter(
      chances,
      fn second_chance -> second_chance.number_of_dice > 0 end
    )
    # transform every chance to a list of modifiers
    |> Enum.map(
      fn second_chance ->
        modifiers_of_second_chance(
          second_chance, event_probability, original_bucket
        )
      end
    )
    |> List.flatten()
    # multiply modifiers to the probability of the source bucket
    |> Enum.map(
      fn bm ->
        %BucketModifier{
          bm | probability: Fraction.multiply(bm.probability, original_bucket.probability)
        }
      end
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
    simulation = %Simulation{},
    :hit_phase
  ) do
    number_of_dice = simulation.attack.number_of_dice
    number_of_fails = number_of_dice - bucket.value
    reroll_type = simulation.attack.hit_modifiers.reroll
    skill = simulation.attack.skill
    probability_to_roll_one = probability_to_roll_one_given_a_miss(skill)
    event_probability = HitRoll.probability_to_hit(skill)

    second_chances(probability_to_roll_one, number_of_fails, reroll_type)
    |> chances_to_modifiers(event_probability, bucket)
    |> append_subtraction_modifier(bucket)
    |> List.flatten()
  end

  def modifiers_of_bucket(
    bucket = %Bucket{},
    simulation = %Simulation{},
    :wound_phase
  ) do
    number_of_dice = length(simulation.result.histogram) - 1
    number_of_fails = number_of_dice - bucket.value
    reroll_type = simulation.attack.wound_modifiers.reroll
    event_probability =
      WoundRoll.probability_to_wound(
        simulation.attack.strenght,
        simulation.defense.resistance
      )
    probability_to_roll_one =
      WoundRoll.probability_to_roll_one_given_a_miss(
        simulation.attack.strenght,
        simulation.defense.resistance
      )
    second_chances(probability_to_roll_one, number_of_fails, reroll_type)
    |> chances_to_modifiers(event_probability, bucket)
    |> append_subtraction_modifier(bucket)
    |> List.flatten()
  end

  @spec modifiers_of_simulation(Simulation.t(), :hit_phase | :wound_phase) :: [BucketModifier.t()]
  def modifiers_of_simulation(simulation = %Simulation{}, phase) do
    Enum.map(
      simulation.result.histogram,  # list of bucket
      fn bucket -> modifiers_of_bucket(bucket, simulation, phase) end
    )
    |> List.flatten()
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

  def apply_modifiers_to_simulation(simulation = %Simulation{}, phase) do
    modifiers = modifiers_of_simulation(simulation, phase)
    histogram =
      Enum.map(
        simulation.result.histogram,
        fn bucket -> apply_modifiers_to_bucket(bucket, modifiers) end
      )

    result =
      %SimulationResult{
        histogram: histogram,
        previous_phase:
          case phase do
            :hit_phase -> :hit_reroll_phase
            :wound_phase -> :wound_reroll_phase
          end
      }

    meta = Map.put(
      simulation.meta,
      :hit_reroll_modifiers, modifiers
    )
    %Simulation{simulation | result: result, meta: meta}
  end

  def simulate_hit_reroll(simulation = %Simulation{}) do
    if simulation.attack.hit_modifiers.reroll == :reroll_none do
      simulation
    else
      simulation |> apply_modifiers_to_simulation(:hit_phase)
    end
  end

  def simulate_wound_reroll(simulation = %Simulation{}) do
    if simulation.attack.wound_modifiers.reroll == :reroll_none do
      simulation
    else
      simulation |> apply_modifiers_to_simulation(:wound_phase)
    end
  end

  @spec simulate(Simulation.t()) :: Simulation.t()
  def simulate(simulation = %Simulation{}) do
    previous_phase = simulation.result.previous_phase
    case previous_phase do
      :hit_phase -> simulate_hit_reroll(simulation)
      :wound_phase -> simulate_wound_reroll(simulation)
    end
  end

end
