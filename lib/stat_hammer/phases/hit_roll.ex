defmodule StatHammer.Phases.HitRoll do
  alias StatHammer.Math.Fraction
  alias StatHammer.Math.Combinations
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

  @spec probability_to_miss(non_neg_integer(), Fraction.t()) :: Fraction.t()
  def probability_to_miss(skill, scenario_probability \\ Fraction.new(1)) do
    Fraction.subtraction(
      Fraction.new(1),
      probability_to_hit(skill, scenario_probability)
    )
  end

  @spec probabilty_to_hit_n_times(non_neg_integer(), non_neg_integer(), non_neg_integer(), Fraction.t()) :: Fraction.t()
  def probabilty_to_hit_n_times(
    skill, number_of_dice, number_of_successes, scenario_probability
  ) do
    Fraction.multiply(
      probabilty_to_hit_n_times(skill, number_of_dice, number_of_successes),
      scenario_probability
    )
  end

  @spec probabilty_to_hit_n_times(non_neg_integer(), non_neg_integer(), non_neg_integer()) :: Fraction.t()
  def probabilty_to_hit_n_times(_skill, number_of_dice, number_of_successes) when number_of_dice < number_of_successes do
    raise ArgumentError, message: "number_of_dice >= number_of_successes"
  end
  def probabilty_to_hit_n_times(skill, number_of_dice, number_of_successes) when number_of_dice == number_of_successes do
    Fraction.pow(probability_to_hit(skill), number_of_dice)
  end
  def probabilty_to_hit_n_times(skill, number_of_dice, 0) do
    Fraction.pow(probability_to_miss(skill), number_of_dice)
  end
  def probabilty_to_hit_n_times(skill, number_of_dice, number_of_successes) do
    hit = Fraction.pow(probability_to_hit(skill), number_of_successes)
    miss = Fraction.pow(probability_to_miss(skill), number_of_dice - number_of_successes)
    single_possible_world = Fraction.multiply(hit, miss)
    Fraction.multiply(
      single_possible_world,
      Combinations.of(number_of_dice, number_of_successes)
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
          probability: probabilty_to_hit_n_times(skill, number_of_dice, x, scenario_probability)
        }
      end
    )
  end

  @spec apply(Simulation.t()) :: Simulation.t()
  def apply(simulation = %Simulation{}) do
    result =
      %SimulationResult{
        histogram: histogram(simulation.attack.skill, simulation.attack.number_of_dice),
        previous_phase: :hit_phase
      }
    %Simulation{simulation | result: result}
  end
end
