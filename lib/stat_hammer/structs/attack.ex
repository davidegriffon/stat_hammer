defmodule StatHammer.Structs.Attack do
  @type t :: %__MODULE__{
    number_of_dice: integer,
    skill: integer,
    strenght: integer,
    armor_penetration: integer
  }

  defstruct [
    :number_of_dice,
    :skill,
    :strenght,
    :armor_penetration
  ]
end
