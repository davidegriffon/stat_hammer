defmodule StatHammer.Structs.SimulationResult do
  alias StatHammer.Math.Histogram

  @type t :: %__MODULE__{
    histogram: Histogram.t(),
    previous_phase: atom(),
  }

  defstruct [
    :histogram,
    :previous_phase,
  ]
end
