defmodule StatHammer.Structs.Simulation do
  alias StatHammer.Structs.Attack
  alias StatHammer.Structs.Defense
  alias StatHammer.Structs.Bucket

  @type t :: %__MODULE__{
    attack: Attack.t(),
    defense: Defense.t(),
    hit_histogram: list(Bucket.t()),
    wound_result: list(),
    saving_result: list(),
    meta: struct(),
  }

  defstruct [
    :attack,
    :defense,
    :hit_histogram,
    :wound_result,
    :saving_result,
    :meta,
  ]
end
