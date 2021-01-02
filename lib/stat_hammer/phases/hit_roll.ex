defmodule StatHammer.Phases.HitRoll do
  alias StatHammer.Math.Fraction
  alias StatHammer.Math.Probability
  alias StatHammer.Structs.Bucket
  alias StatHammer.Structs.Simulation
  alias StatHammer.Structs.SimulationResult

  @spec probability_to_hit(non_neg_integer(), Fraction.t()) :: Fraction.t()
  def probability_to_hit(skill, scenario_probability \\ Fraction.new(1))
  def probability_to_hit(skill, _scenario_probability) when not is_integer(skill) do
    raise ArgumentError, message: "Skill must be an integer"
  end
  def probability_to_hit(skill, _scenario_probability) when skill < 2 or skill > 6 do
    raise ArgumentError, message: "Skill must be in range 2...6"
  end
  def probability_to_hit(skill, scenario_probability) do
    Fraction.multiply(
      Fraction.new(7 - skill, 6),
      scenario_probability
    )
  end

  @spec histogram(non_neg_integer(), non_neg_integer(), Fraction.t()) :: list(Bucket.t())
  def histogram(skill, number_of_dice, scenario_probability \\ Fraction.new(1))
  def histogram(skill, _number_of_dice, _scenario_probability) when skill < 2 or skill > 6 do
    raise ArgumentError, message: "Skill must be in range 2...6"
  end
  def histogram(_skill, number_of_dice, _scenario_probability) when number_of_dice < 1 or number_of_dice > 50 do
    raise ArgumentError, message: "Number of dice must be in range 1..50"
  end
  def histogram(skill, number_of_dice, scenario_probability) do
    Enum.map(
      0..number_of_dice,
      fn x ->
        %Bucket{
          value: x,
          probability:
            Probability.probabilty_to_success_n_times(
              probability_to_hit(skill), number_of_dice, x, scenario_probability
            )
        }
      end
    )
  end

  @spec apply(Simulation.t()) :: Simulation.t()
  def apply(simulation = %Simulation{}) do
    calculated_histogram =
      histogram(simulation.attack.skill, simulation.attack.number_of_dice)
    result =
      %SimulationResult{
        histogram: calculated_histogram,
        previous_phase: :hit_phase
      }
    meta = Map.put(
      simulation.meta,
      :hit_phase_histogram, calculated_histogram
    )
    %Simulation{simulation | result: result, meta: meta}
  end
end
