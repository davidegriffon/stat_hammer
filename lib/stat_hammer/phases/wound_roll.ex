defmodule StatHammer.Phases.WoundRoll do
  alias StatHammer.Math.Fraction
  alias StatHammer.Math.Combinations
  alias StatHammer.Structs.Bucket
  alias StatHammer.Structs.Simulation
  alias StatHammer.Structs.SimulationResult

  @spec probability_to_wound(non_neg_integer(), non_neg_integer()) :: Fraction.t()
  def probability_to_wound(strenght, resistance) when (strenght / 2) >= resistance do
    Fraction.new(5, 6)
  end
  def probability_to_wound(strenght, resistance) when strenght > resistance do
    Fraction.new(4, 6)
  end
  def probability_to_wound(strenght, resistance) when strenght == resistance do
    Fraction.new(3, 6)
  end
  def probability_to_wound(strenght, resistance) when (strenght / 2) <= resistance do
    Fraction.new(1, 6)
  end
  def probability_to_wound(strenght, resistance) when strenght < resistance do
    Fraction.new(2, 6)
  end

  def probability_not_to_wound(
    strenght, resistance, scenario_probability \\ Fraction.new(1)
  ) do
    Fraction.subtraction(
      Fraction.new(1),
      probability_to_wound(strenght, resistance, scenario_probability)
    )
  end

  def probability_to_wound(strenght, resistance, scenario_probability) do
    Fraction.multiply(
      probability_to_wound(strenght, resistance),
      scenario_probability
    )
  end

  @spec probabilty_to_wound_n_times(
    non_neg_integer(), non_neg_integer(), non_neg_integer(), non_neg_integer()
  ) :: Fraction.t()
  def probabilty_to_wound_n_times(
    _strenght, _resistance, number_of_dice, number_of_successes
  ) when number_of_dice < number_of_successes do
    raise ArgumentError, message: "number_of_dice >= number_of_successes"
  end
  def probabilty_to_wound_n_times(
    strenght, resistance, number_of_dice, number_of_successes
  ) when number_of_dice == number_of_successes do
    Fraction.pow(probability_to_wound(strenght, resistance), number_of_dice)
  end
  def probabilty_to_wound_n_times(
    strenght, resistance, number_of_dice, 0
  ) do
    Fraction.pow(probability_not_to_wound(strenght, resistance), number_of_dice)
  end
  def probabilty_to_wound_n_times(
    strenght, resistance, number_of_dice, number_of_successes
  ) do
    wound = Fraction.pow(
      probability_to_wound(strenght, resistance), number_of_successes
    )
    not_wound = Fraction.pow(
      probability_not_to_wound(strenght, resistance),
      number_of_dice - number_of_successes
    )
    single_possible_world = Fraction.multiply(wound, not_wound)
    Fraction.multiply(
      single_possible_world,
      Combinations.of(number_of_dice, number_of_successes)
    )
  end

  def probabilty_to_wound_n_times(
    strenght, resistance, number_of_dice, number_of_successes, scenario_probability
  ) do
    Fraction.multiply(
      probabilty_to_wound_n_times(strenght, resistance, number_of_dice, number_of_successes),
      scenario_probability
    )
  end

  def sub_histogram_of_bucket(bucket = %Bucket{}, strenght, resistance) do
    Enum.map(
      0..bucket.value,
      fn number_of_successes ->
        %Bucket{
          value: number_of_successes,
          probability: probabilty_to_wound_n_times(
            strenght, resistance, bucket.value, number_of_successes, bucket.probability
          )
        }
      end
    )
  end

  @spec merge(list(Bucket.t())) :: list(Bucket.t())
  def merge(histogram) do
    histogram
    |> Enum.group_by(
      fn bucket -> bucket.value end
    )
    |> Map.values()
    |> Enum.map(
      fn bucket_list ->
        Enum.reduce(
          bucket_list,
          fn partial_bucket, bucket ->
            %Bucket{
              value: bucket.value,
              probability: Fraction.add(partial_bucket.probability, bucket.probability)
            }
          end
        )
      end
    )
    |> Enum.sort_by(&(&1.value))
  end

  def histogram(hit_histogram, strenght, resistance) do
    # for each bucket (from hit phase) calculate sub-histograms
    Enum.map(
      hit_histogram,
      fn bucket ->
        sub_histogram_of_bucket(bucket, strenght, resistance)
      end
    )
    |> List.flatten()
    |> merge()
  end

  @spec apply(Simulation.t()) :: Simulation.t()
  def apply(simulation = %Simulation{}) do
    result =
      %SimulationResult{
        histogram: histogram(
          simulation.result.histogram,
          simulation.attack.strenght,
          simulation.defense.resistance
        ),
        previous_phase: :wound_phase
      }
    %Simulation{simulation | result: result}
  end

end
