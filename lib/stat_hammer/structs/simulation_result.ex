defmodule StatHammer.Structs.SimulationResult do
  @type t :: %__MODULE__{
    histogram: list(Bucket.t()),
    previous_phase: atom(),
  }

  defstruct [
    :histogram,
    :previous_phase,
  ]
end
