defmodule StatHammer.Structs.Histogram do
  alias StatHammer.Structs.HistogramValue

  def merge(first, second) do
    {first, second}
  end

end

defmodule StatHammer.Structs.HistogramValue do
  alias StatHammer.Math.Fraction
  alias StatHammer.Structs.HistogramValue

  @type t :: %__MODULE__{
    key: non_neg_integer(),
    value: Fraction.t(),
  }

  defstruct [
    :key,
    :value,
  ]

  def from_tuple({key, value}) do
    %HistogramValue{
      key: key,
      value: value,
    }
  end
end
