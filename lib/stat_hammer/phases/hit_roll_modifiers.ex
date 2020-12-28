defmodule StatHammer.Phases.HitRoll.Modifieds do
  alias StatHammer.Math.Fraction
  alias StatHammer.Structs.HistogramValue
  alias StatHammer.Phases.HitRoll

  @doc """
  The probability to roll 1 is the same as to hit with bs/ws 6+.
  For this reason we reuse the function HitRoll.probabilty_to_hit_n_times
  """
  def probabiliy_to_roll_one_n_times(number_of_dice, number_of_ones) do
    HitRoll.probabilty_to_hit_n_times(6, number_of_dice, number_of_ones)
  end

  def determine_number_of_rerolls(histogram_value = %HistogramValue{}, original_number_of_dice, :reroll_ones) do
    # note: `key` represent the number of hits, `value` the probability of this scenario
    number_of_hits = histogram_value.key
    scenario_probability = histogram_value.value
    # calculate histogram of number of ones
    number_of_reroll = original_number_of_dice - number_of_hits
    number_of_ones_histogram = Enum.map(
      0..number_of_reroll,
      fn n -> %HistogramValue{
        key: n,
        value: probabiliy_to_roll_one_n_times(n, number_of_reroll)
      } end
    )
    # multiply the new histogram with the probability of this scenario
    Enum.map(
      number_of_ones_histogram,
      fn hv -> %HistogramValue{
        key: hv.key,
        value: Fraction.multiply(hv.value, scenario_probability)
      } end
    )
  end
end
