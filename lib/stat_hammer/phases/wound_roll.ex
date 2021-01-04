defmodule StatHammer.Phases.WoundRoll do
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

  def histogram(hit_histogram, strenght, resistance) do
    Enum.map(
      hit_histogram,
      fn bucket ->
        # for each bucket (from hit phase) calculate sub-histograms
        Histogram.generate(
          probability_to_wound(strenght, resistance),
          bucket.value,
          bucket.probability
        )
      end
    )
    |> List.flatten()
    |> Histogram.merge()
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
