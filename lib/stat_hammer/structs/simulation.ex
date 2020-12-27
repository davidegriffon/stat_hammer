defmodule StatHammer.Structs.Simulation do
  alias StatHammer.Structs.Attack
  alias StatHammer.Structs.Defense

  @type t :: %__MODULE__{
    attack: Attack.t,
    defense: Defense.t,
    hit_result: List.t,
    wound_result: List.t,
    saving_result: List.t,
  }

  defstruct [
    :attack,
    :defense,
    :hit_result,
    :wound_result,
    :saving_result
  ]
end
