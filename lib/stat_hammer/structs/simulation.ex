defmodule StatHammer.Structs.Simulation do
  alias StatHammer.Structs.Attack
  alias StatHammer.Structs.Defense

  @type t :: %__MODULE__{
    attack: Attack.t(),
    defense: Defense.t(),
    hit_histogram: list(),
    wound_result: list(),
    saving_result: list(),
  }

  defstruct [
    :attack,
    :defense,
    :hit_histogram,
    :wound_result,
    :saving_result
  ]
end
