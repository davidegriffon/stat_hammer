defmodule StatHammer.Phases.WoundRoll do
  alias StatHammer.Math.Fraction
  alias StatHammer.Math.Probability
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

  def child_histogram_of_bucket(bucket = %Bucket{}, strenght, resistance) do
    probability = probability_to_wound(strenght, resistance)
    Enum.map(
      0..bucket.value,
      fn number_of_successes ->
        %Bucket{
          value: number_of_successes,
          probability:
            Probability.probabilty_to_success_n_times(
              probability, bucket.value, number_of_successes, bucket.probability
            )
        }
      end
    )
  end

  @spec merge(list(Bucket.t())) :: list(Bucket.t())
  def merge(histogram) do
    histogram
    |> Enum.group_by(fn bucket -> bucket.value end)
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
        child_histogram_of_bucket(bucket, strenght, resistance)
      end
    )
    |> List.flatten()
    |> merge()
  end

  @spec simulate(Simulation.t()) :: Simulation.t()
  def simulate(simulation = %Simulation{}) do
    updated_histogram =
      histogram(
        simulation.result.histogram,
        simulation.attack.strenght,
        simulation.defense.resistance
      )
    result =
      %SimulationResult{
        histogram: updated_histogram,
        previous_phase: :wound_phase
      }
    %Simulation{simulation | result: result}
  end

end
