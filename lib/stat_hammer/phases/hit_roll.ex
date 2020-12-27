defmodule StatHammer.Phases.HitRoll do
  alias StatHammer.Math.Fraction
  alias StatHammer.Math.Combinations
  alias StatHammer.Structs.Simulation

  def probability_to_hit(skill) when not is_integer(skill) do
    raise ArgumentError, message: "Skill must be an integer"
  end
  def probability_to_hit(skill) when skill < 2 or skill > 6 do
    raise ArgumentError, message: "Skill must be in range 2...6"
  end
  def probability_to_hit(skill) do
    Fraction.new(7 - skill, 6)
  end

  def probability_to_hit(skill, _number_of_dice) when skill < 2 or skill > 6 do
    raise ArgumentError, message: "Skill must be in range 2...6"
  end
  def probability_to_hit(_skill, number_of_dice) when number_of_dice < 1 or number_of_dice > 50 do
    raise ArgumentError, message: "Number of dice must be in range 1..50"
  end

  def probability_to_hit(skill, number_of_dice) do
    Enum.map(
      0..number_of_dice,
      fn x -> {x, probabilty_to_hit_n_times(skill, number_of_dice, x)} end
    )
  end

  def probability_to_miss(skill) do
    Fraction.subtraction(Fraction.new(1), probability_to_hit(skill))
  end

  @spec probabilty_to_hit_n_times(non_neg_integer, non_neg_integer, non_neg_integer) :: Fraction.t()
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
    possible_world = Fraction.multiply(hit, miss)

    Fraction.multiply(
      possible_world,
      Combinations.of(number_of_dice, number_of_successes)
    )
  end

  @spec calculate(Simulation.t()) :: Simulation.t()
  def calculate(simulation = %Simulation{}) do
    hit_result = probability_to_hit(simulation.attack.skill, simulation.attack.number_of_dice)
    %{simulation | hit_result: hit_result}
  end
end
