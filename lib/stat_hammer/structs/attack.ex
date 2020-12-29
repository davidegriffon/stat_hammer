defmodule StatHammer.Structs.Attack do
  alias StatHammer.Structs.Attack.HitModifiers

  @type t :: %__MODULE__{
    number_of_dice: non_neg_integer(),
    skill: non_neg_integer(),
    strenght: non_neg_integer(),
    armor_penetration: non_neg_integer(),
    hit_modifiers: HitModifiers.t(),
  }

  defstruct [
    :number_of_dice,
    :skill,
    :strenght,
    :armor_penetration,
    :hit_modifiers,
  ]
end

defmodule StatHammer.Structs.Attack.HitModifiers do
  @type t :: %__MODULE__{
    reroll: atom(), # :reroll_ones, :reroll_all, :reroll_none
    on_six: atom(), # :on_six_two_hits, :on_six_three_hits, :on_six_none
  }

  defstruct [
    :reroll,
    :on_six,
  ]
end
