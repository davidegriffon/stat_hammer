defmodule StatHammer.Phases.HitRoll do
  alias StatHammer.Math.Fraction
  alias StatHammer.Math.Histogram
  alias StatHammer.Structs.Simulation
  alias StatHammer.Structs.SimulationResult

  @spec probability_to_hit(non_neg_integer()) :: Fraction.t()
  def probability_to_hit(skill) when not is_integer(skill) do
    raise ArgumentError, message: "Skill must be an integer"
  end
  def probability_to_hit(skill) when skill < 2 or skill > 6 do
    raise ArgumentError, message: "Skill must be in range 2...6"
  end
  def probability_to_hit(skill) do
    Fraction.new(7 - skill, 6)
  end

  @spec simulate(Simulation.t()) :: Simulation.t()
  def simulate(simulation = %Simulation{}) do
    hit_histogram =
      Histogram.generate(probability_to_hit(simulation.attack.skill), simulation.attack.number_of_dice)
    result =
      %SimulationResult{
        histogram: hit_histogram,
        previous_phase: :hit_phase
      }
    meta = Map.put(
      simulation.meta,
      :hit_phase_histogram, hit_histogram
    )
    %Simulation{simulation | result: result, meta: meta}
  end
end
