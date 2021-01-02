defmodule StatHammer.Math.Probability do
  alias StatHammer.Math.Fraction
  alias StatHammer.Math.Combinations

  @spec inverse_probability(Fraction.t()) :: Fraction.t()
  def inverse_probability(probability) do
    Fraction.subtraction(
      Fraction.new(1),
      probability
    )
  end

  @spec probabilty_to_success_n_times(
    Fraction.t(), non_neg_integer(), non_neg_integer(), Fraction.t()
  ) :: Fraction.t()
  def probabilty_to_success_n_times(
    probability, number_of_dice, number_of_successes, scenario_probability
  ) do
    Fraction.multiply(
      probabilty_to_success_n_times(probability, number_of_dice, number_of_successes),
      scenario_probability
    )
  end

  @spec probabilty_to_success_n_times(
    Fraction.t(), non_neg_integer(), non_neg_integer()
  ) :: Fraction.t()
  def probabilty_to_success_n_times(_probability, number_of_dice, number_of_successes) when number_of_dice < number_of_successes do
    raise ArgumentError, message: "number_of_dice >= number_of_successes"
  end
  def probabilty_to_success_n_times(probability, number_of_dice, number_of_successes) when number_of_dice == number_of_successes do
    Fraction.pow(probability, number_of_dice)
  end
  def probabilty_to_success_n_times(probability, number_of_dice, 0) do
    Fraction.pow(inverse_probability(probability), number_of_dice)
  end
  def probabilty_to_success_n_times(probability, number_of_dice, number_of_successes) do
    hit = Fraction.pow(probability, number_of_successes)
    miss = Fraction.pow(inverse_probability(probability), number_of_dice - number_of_successes)
    single_possible_world = Fraction.multiply(hit, miss)
    Fraction.multiply(
      single_possible_world,
      Combinations.of(number_of_dice, number_of_successes)
    )
  end

end
