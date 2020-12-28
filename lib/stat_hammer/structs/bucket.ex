defmodule StatHammer.Structs.Bucket do
  alias StatHammer.Math.Fraction
  alias StatHammer.Structs.Bucket

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
end
