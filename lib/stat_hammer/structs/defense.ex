defmodule StatHammer.Structs.Defense do
  @type t :: %__MODULE__{
    resistance: non_neg_integer(),
    wounds: non_neg_integer(),
    save: non_neg_integer(),
    invulnerable: non_neg_integer()
  }

  defstruct [
    :resistance,
    :wounds,
    :save,
    :invulnerable
  ]
end
