defmodule StatHammer.Structs.SecondChance do
  alias StatHammer.Math.Fraction
  alias StatHammer.Structs.Histogram
  alias StatHammer.Math.Probability
  alias StatHammer.Structs.SecondChance

  @type t :: %__MODULE__{
    number_of_dice: non_neg_integer(),
    probability: Fraction.t(),
    original_bucket: Bucket.t(),
  }

  defstruct [
    :number_of_dice,
    :probability,
    :original_bucket,
  ]

  @spec second_chances(
    Fraction.t(), non_neg_integer(), :reroll_all | :reroll_ones | :reroll_none, Bucket.t()
  ) :: list(SecondChance.t())
  def second_chances(_probability_to_roll_one, _number_of_fails, :reroll_none, _original_bucket) do
    []
  end
  def second_chances(_probability_to_roll_one, 0, _type, _original_bucket) do
    []
  end
  def second_chances(
    %Fraction{numerator: 1, denominator: 1}, number_of_fails, :reroll_ones, original_bucket
  ) do
    [
      %SecondChance{
        number_of_dice: number_of_fails,
        probability: original_bucket.probability,
        original_bucket: original_bucket
      }
    ]
  end
  def second_chances(_probability_to_roll_one, number_of_fails, :reroll_all, original_bucket) do
    [
      %SecondChance{
        number_of_dice: number_of_fails,
        probability: original_bucket.probability,
        original_bucket: original_bucket
      }
      ]
  end
  def second_chances(probability_to_roll_one, number_of_fails, :reroll_ones, original_bucket) do
    # note: this list contains also 0 `number_of_fails` even if not necessary
    #       this is useful for test because the sum of probabilities must be 1
    chances = Enum.map(
      0..number_of_fails, # see above
      fn number_of_ones ->
        %SecondChance{
          number_of_dice: number_of_ones,
          probability:
            Probability.probabilty_to_success_n_times(
              probability_to_roll_one,
              number_of_fails,
              number_of_ones,
              original_bucket.probability
            ),
          original_bucket: original_bucket
        }
      end
    )
    chances
  end

  def second_chances_of_histogram(
    histogram = %Histogram{}, probability_to_roll_one, reroll_type
  ) do
    Enum.map(
      histogram.buckets,
      fn bucket ->
        number_of_fails = histogram.number_of_dice - bucket.value
        second_chances(
          probability_to_roll_one,
          number_of_fails,
          reroll_type,
          bucket
        )
      end
    )
    # merge chances of all buckets
    |> List.flatten()
    # remove chances of 0 number_of_dice
    |> Enum.filter(fn chance -> chance.number_of_dice > 0 end)
  end

end
