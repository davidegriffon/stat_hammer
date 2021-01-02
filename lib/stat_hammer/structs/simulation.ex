defmodule StatHammer.Structs.Simulation do
  alias StatHammer.Structs.Attack
  alias StatHammer.Structs.Defense
  alias StatHammer.Structs.SimulationResult

  @type t :: %__MODULE__{
    attack: Attack.t(),
    defense: Defense.t(),
    result: SimulationResult.t(),
    meta: struct(),
  }

  defstruct [
    :attack,
    :defense,
    :result,
    :meta,
  ]
end
