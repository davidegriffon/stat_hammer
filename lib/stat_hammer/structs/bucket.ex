defmodule StatHammer.Structs.Bucket do
  alias StatHammer.Math.Fraction
  alias StatHammer.Structs.Bucket
  alias StatHammer.Structs.BucketModifier

  @type t :: %__MODULE__{
    value: non_neg_integer(),
    probability: Fraction.t(),
  }

  defstruct [
    :value,
    :probability,
  ]

  def from_tuple({value, probability}) do
    %Bucket{
      value: value,
      probability: probability,
    }
  end

  def apply_modifier_to_bucket(
    bucket = %Bucket{value: bucket_value},
    modifier = %BucketModifier{bucket_value: bucket_value}
  ) do
    new_probability =
      case modifier.type do
        :add -> Fraction.add(bucket.probability, modifier.probability)
        :subtraction -> Fraction.subtraction(bucket.probability, modifier.probability)
      end
    %Bucket{
      value: bucket_value,
      probability: new_probability
    }
  end
  def apply_modifier_to_bucket(
    bucket = %Bucket{},
    _modifier = %BucketModifier{}
  ) do
    bucket
  end

  def apply_modifiers_to_bucket(
    bucket = %Bucket{}, bucket_modifiers
  ) do
    Enum.reduce(
      bucket_modifiers,
      bucket,
      fn modifier, bucket ->
        apply_modifier_to_bucket(bucket, modifier)
      end
    )
  end

end
