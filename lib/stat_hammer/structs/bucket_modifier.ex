defmodule StatHammer.Structs.BucketModifier do
  @type t :: %__MODULE__{
    type: :add | :subtract,
    bucket_value: non_neg_integer(),
    probability: Fraction.t(),
  }

  defstruct [
    :type,
    :bucket_value,
    :probability,
  ]
end
