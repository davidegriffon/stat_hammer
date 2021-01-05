defmodule StatHammer.Structs.SimulationResult do
  alias StatHammer.Structs.Histogram

  @type t :: %__MODULE__{
    histogram: Histogram.t(),
    previous_phase: atom(),
  }

  defstruct [
    :histogram,
    :previous_phase,
  ]
end
