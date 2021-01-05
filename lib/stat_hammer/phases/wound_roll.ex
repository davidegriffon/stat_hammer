defmodule StatHammer.Phases.WoundRoll do
  import Logger

  alias StatHammer.Math.Fraction
  alias StatHammer.Math.Histogram
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

  def probability_to_roll_one_given_a_miss(strenght, resistance) do
    not_to_wound =
      Fraction.subtraction(
        Fraction.new(1),
        probability_to_wound(strenght, resistance)
      )
    Fraction.division(Fraction.new(1, 6), not_to_wound)
  end

  def wound_sub_histograms(hit_histogram = %Histogram{}, strenght, resistance) do
    wound_sub_histograms =
      Enum.map(
        hit_histogram.buckets,
        fn bucket ->
          # for each bucket (from hit phase) calculate sub-histograms
          sub_histogram = Histogram.generate(
            probability_to_wound(strenght, resistance),
            bucket.value,
            bucket.probability
          )
          Logger.debug("sub_histogram of bucket #{bucket.value}")
          Logger.debug("sub_histogram of bucket #{bucket.value}")
          #IO.inspect(sub_histogram)
          Logger.debug("\n")
          sub_histogram
        end
      )
    wound_sub_histograms
  end

  def simulate(simulation = %Simulation{}) do
    sub_histograms =
      wound_sub_histograms(
        simulation.result.histogram,
        simulation.attack.strenght,
        simulation.defense.resistance
      )

    wound_histogram =
      sub_histograms
      |> Histogram.merge()

    result =
      %SimulationResult{
        histogram: wound_histogram,
        previous_phase: :wound_phase
      }

    meta =
      simulation.meta
      |> Map.put(:wound_phase_sub_histograms, sub_histograms)
      |> Map.put(:wound_phase_histogram, wound_histogram)

    %Simulation{simulation | result: result, meta: meta}
  end

end
