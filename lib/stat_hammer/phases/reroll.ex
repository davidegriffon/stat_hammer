defmodule StatHammer.Phases.Reroll do
  alias StatHammer.Math.Fraction
  alias StatHammer.Math.Combinations
  alias StatHammer.Structs.Simulation
  alias StatHammer.Structs.SecondChance
  alias StatHammer.Structs.Bucket
  alias StatHammer.Structs.BucketModifier
  alias StatHammer.Phases.HitRoll

  defp probabiliy_to_roll_one_given_a_miss(skill) do
    Fraction.new(1, skill - 1)
  end

  @doc """
  Calcutate the probability to roll `number_of_ones` ones rolling `number_of_fails` dice.
  Note that dice in this context are all misses, so the probability to get a `one` depends on skill.
  """
  def probabiliy_to_roll_one_n_times(_skill, number_of_fails, number_of_ones) when number_of_fails < number_of_ones do
    raise ArgumentError, message: "number_of_fails >= number_of_ones"
  end
  def probabiliy_to_roll_one_n_times(skill, number_of_fails, number_of_ones) when number_of_fails == number_of_ones do
    Fraction.pow(probabiliy_to_roll_one_given_a_miss(skill), number_of_fails)
  end
  def probabiliy_to_roll_one_n_times(skill, number_of_fails, 0) do
    Fraction.pow(
      Fraction.subtraction(Fraction.new(1), probabiliy_to_roll_one_given_a_miss(skill)),
      number_of_fails
    )
  end
  def probabiliy_to_roll_one_n_times(skill, number_of_fails, number_of_ones) do
    probability_to_roll_one = probabiliy_to_roll_one_given_a_miss(skill)
    ones = Fraction.pow(probability_to_roll_one, number_of_ones)
    non_ones = Fraction.pow(Fraction.subtraction(Fraction.new(1), probability_to_roll_one), number_of_fails - number_of_ones)
    single_possible_world = Fraction.multiply(ones, non_ones)
    Fraction.multiply(
      single_possible_world,
      Combinations.of(number_of_fails, number_of_ones)
    )
  end

  @spec get_second_chances(non_neg_integer(), non_neg_integer(), :reroll_all | :reroll_ones | :reroll_none) :: list(SecondChance.t())
  def get_second_chances(_skill, _number_of_fails, :reroll_none) do
    []
  end
  def get_second_chances(_skill, 0, _type) do
    []
  end
  def get_second_chances(2, number_of_fails, :reroll_ones) do
    [%SecondChance{number_of_dice: number_of_fails, probability: Fraction.new(1)}]
  end
  def get_second_chances(_skill, number_of_fails, :reroll_all) do
    [%SecondChance{number_of_dice: number_of_fails, probability: Fraction.new(1)}]
  end
  def get_second_chances(skill, number_of_fails, :reroll_ones) do
    # note: contains also 0 even if not necessary, this is useful for test because the sum of this list must be 1
    second_chances = Enum.map(
      0..number_of_fails, # see above
      fn number_of_ones -> %SecondChance{
        number_of_dice: number_of_ones,
        probability: probabiliy_to_roll_one_n_times(skill, number_of_fails, number_of_ones)
      } end
    )
    second_chances
  end

  def chance_to_modifiers(second_chance = %SecondChance{}, skill, original_bucket) do
    HitRoll.hit_histogram(
      skill,
      second_chance.number_of_dice,
      second_chance.probability
    )
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
  def chances_to_modifiers(chances, skill, original_bucket) do
    # get rid of SecondChance with number_of_dice equals to 0
    Enum.filter(
      chances,
      fn chance -> chance.number_of_dice > 0 end
    )
    # transform every chance to modifiers
    |> Enum.map(
      fn chance -> chance_to_modifiers(chance, skill, original_bucket) end
    )
    |> List.flatten()
  end

  def get_modifiers_from_bucket(bucket = %Bucket{}, simulation = %Simulation{}) do
    skill = simulation.attack.skill
    number_of_dice = simulation.attack.number_of_dice
    reroll_type = simulation.attack.hit_modifiers.reroll
    number_of_fails = number_of_dice - bucket.value

    add_modifiers =
      get_second_chances(skill, number_of_fails, reroll_type)
      |> chances_to_modifiers(skill, bucket)
      # multiply modifiers to the probability of the source bucket
      |> Enum.map(
        fn bm -> %BucketModifier{
          bm | probability: Fraction.multiply(bm.probability, bucket.probability)
        } end
      )

    cumulative_probability_of_add_modifiers =
      Enum.reduce(
        add_modifiers,
        Fraction.new(0),
        fn bm, acc -> Fraction.add(bm.probability, acc) end
      )

    # add subtraction modifier for the source bucket
    modifiers = [
      %BucketModifier{
        type: :subtraction,
        bucket_value: bucket.value,
        probability: cumulative_probability_of_add_modifiers
      } | add_modifiers
    ]

    modifiers
    |> List.flatten()
  end

  @spec get_modifiers(Simulation.t()) :: Simulation.t()
  def get_modifiers(simulation = %Simulation{}) do
    modifiers =
      Enum.map(
        simulation.hit_histogram,  # list of bucket
        fn bucket -> get_modifiers_from_bucket(bucket, simulation) end
      )
      |> List.flatten()

    meta = Map.put(simulation.meta, :hit_reroll_modifiers, modifiers)
    %Simulation{simulation | meta: meta}
  end

  @spec apply_modifiers(Simulation.t()) :: Simulation.t()
  def apply_modifiers(simulation = %Simulation{}) do
    # normalize modifiers
    # TODO
    simulation
  end

  @spec apply(Simulation.t()) :: Simulation.t()
  def apply(simulation = %Simulation{}) do
    if simulation.attack.hit_modifiers.reroll == :reroll_none do
      simulation
    else
      simulation
      |> get_modifiers()
      |> apply_modifiers()
    end
  end

end
