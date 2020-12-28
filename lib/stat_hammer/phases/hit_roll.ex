defmodule StatHammer.Phases.HitRoll do
  alias StatHammer.Math.Fraction
  alias StatHammer.Math.Combinations
  alias StatHammer.Structs.HistogramValue
  alias StatHammer.Structs.Simulation

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
  def probabilty_to_hit_n_times(skill, number_of_dice, number_of_successes, scenario_probability) do
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

  @spec hit_histogram(non_neg_integer(), non_neg_integer(), Fraction.t()) :: list(HistogramValue.t())
  def hit_histogram(skill, number_of_dice, scenario_probability \\ Fraction.new(1))
  def hit_histogram(skill, _number_of_dice, _scenario_probability) when skill < 2 or skill > 6 do
    raise ArgumentError, message: "Skill must be in range 2...6"
  end
  def hit_histogram(_skill, number_of_dice, _scenario_probability) when number_of_dice < 1 or number_of_dice > 50 do
    raise ArgumentError, message: "Number of dice must be in range 1..50"
  end
  def hit_histogram(skill, number_of_dice, scenario_probability) do
    Enum.map(
      0..number_of_dice,
      fn x -> %HistogramValue{key: x, value: probabilty_to_hit_n_times(skill, number_of_dice, x, scenario_probability)} end
    )
  end

  def apply_reroll(hit_histogram, _number_of_dice, nil) do
    hit_histogram
  end
  def apply_reroll(hit_histogram, _number_of_dice, :reroll_ones) do
    # [{0, 1/2}, {1, 2/3}, ...]

    hit_histogram
  end
  def apply_reroll(hit_histogram, _number_of_dice, :reroll_all) do
    # TODO
    hit_histogram
  end

  def apply_six_rolls(hit_histogram, _number_of_dice, nil) do
    hit_histogram
  end
  def apply_six_rolls(hit_histogram, _number_of_dice, :on_six_two_hits) do
    # TODO
    hit_histogram
  end
  def apply_six_rolls(hit_histogram, _number_of_dice, :on_six_three_hits) do
    # TODO
    hit_histogram
  end

  @spec calculate(Simulation.t()) :: Simulation.t()
  def calculate(simulation = %Simulation{}) do
    hit_histogram =
      hit_histogram(simulation.attack.skill, simulation.attack.number_of_dice)
      |> apply_reroll(simulation.attack.number_of_dice, simulation.attack.hit_modifiers.reroll)
      |> apply_six_rolls(simulation.attack.number_of_dice, simulation.attack.hit_modifiers.on_six)
    %Simulation{simulation | hit_histogram: hit_histogram}
  end
end
