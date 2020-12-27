defmodule StatHammer.Structs.Defense do
  @type t :: %__MODULE__{
    resistance: integer,
    wounds: integer,
    save: integer,
    invulnerable: integer
  }

  defstruct [
    :resistance,
    :wounds,
    :save,
    :invulnerable
  ]
end
