defmodule StatHammer.Structs.BucketModifier do
  alias StatHammer.Math.Fraction
  alias StatHammer.Math.Histogram
  alias StatHammer.Structs.Bucket
  alias StatHammer.Structs.BucketModifier
  alias StatHammer.Structs.SecondChance

  @type t :: %__MODULE__{
    type: :add | :subtract,
    bucket_value: non_neg_integer(),
    probability: Fraction.t(),
    original_bucket: Bucket.t(),
  }

  defstruct [
    :type,
    :bucket_value,
    :probability,
    :original_bucket,
  ]

  @spec modifiers_of_second_chances(
    list(SecondChance.t()), Fraction.t()
  ) :: list(BucketModifier.t())
  def modifiers_of_second_chances(chances, event_probability) do
    # get rid of SecondChance with number_of_dice equals to 0
    Enum.filter(
      chances,
      fn second_chance -> second_chance.number_of_dice > 0 end
    )
    # transform every chance to a list of modifiers
    |> Enum.map(
      fn second_chance ->
        modifiers_of_second_chance(
          second_chance, event_probability
        )
      end
    )
    |> List.flatten()
  end

  def modifiers_of_second_chance(
    second_chance = %SecondChance{},
    event_probability
  ) do
    # first step: generate an histogram
    histogram =
      Histogram.generate(
        event_probability,
        second_chance.number_of_dice,
        second_chance.probability
      )
    # second step: remove bucket of 0 value, it means no reroll
    histogram.buckets
    |> Enum.filter(
      fn bucket -> bucket.value > 0 end
    )
    # third step: # transform list of %Bucket{} in a list of %BucketModifier
    |> Enum.map(
      fn bucket ->
        %BucketModifier{
          type: :add,
          bucket_value: bucket.value + second_chance.original_bucket.value,
          probability: bucket.probability,
          original_bucket: second_chance.original_bucket
        }
      end
    )
    # fourth step: append subtraction modifier
    |> append_subtraction_modifier(second_chance.original_bucket.value)
  end

  def append_subtraction_modifier([], _bucket_value) do
    []
  end
  def append_subtraction_modifier(add_modifiers, bucket_value) do
    cumulative_probability_of_add_modifiers =
      Enum.reduce(
        add_modifiers,
        Fraction.new(0),
        fn bm, acc -> Fraction.add(bm.probability, acc) end
      )
    subtraction_modifier =
      %BucketModifier{
        type: :subtraction,
        bucket_value: bucket_value,
        probability: cumulative_probability_of_add_modifiers,
        original_bucket: nil # we don't need it in subtraction modifier
      }
    # append subtraction modifier for the source bucket
    [subtraction_modifier | add_modifiers]
  end

end
