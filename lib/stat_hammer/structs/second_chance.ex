defmodule StatHammer.Structs.SecondChance do
  alias StatHammer.Math.Fraction

  @type t :: %__MODULE__{
    number_of_dice: non_neg_integer(),
    probability: Fraction.t(),
  }

  defstruct [
    :number_of_dice,
    :probability,
  ]
end
