defmodule StatHammer.Structs.Histogram do
  alias StatHammer.Math.Probability
  alias StatHammer.Math.Fraction
  alias StatHammer.Structs.Histogram
  alias StatHammer.Structs.Bucket

  @type t :: %__MODULE__{
    number_of_dice: non_neg_integer(),
    buckets: list(Bucket.t()),
  }

  defstruct [
    :number_of_dice,
    :buckets,
  ]

  @spec generate(
    Fraction.t(), non_neg_integer(), Fraction.t()
  ) :: Histogram.t()
  def generate(
    event_probability, number_of_events, scenario_probability \\ Fraction.new(1)
  )
  def generate(
    event_probability, number_of_events, scenario_probability
  ) do
    buckets =
      Enum.map(
        0..number_of_events,
        fn number_of_successful_events ->
          %Bucket{
            value: number_of_successful_events,
            probability:
              Probability.probabilty_to_success_n_times(
                event_probability, number_of_events, number_of_successful_events, scenario_probability
              )
          }
        end
      )
    %Histogram{
      number_of_dice: number_of_events,
      buckets: buckets
    }
  end

  @spec merge(list(Histogram.t())) :: Histogram.t()
  def merge(histograms) do
    number_of_dice =
      histograms
      |> Enum.map(fn histogram -> histogram.number_of_dice end)
      |> Enum.max()

    buckets =
      histograms
      |> Enum.map(fn histogram -> histogram.buckets end)
      |> List.flatten()
      |> Enum.group_by(fn bucket -> bucket.value end)
      |> Map.values()
      |> Enum.map(
        fn bucket_list ->
          Enum.reduce(
            bucket_list,
            fn partial_bucket, bucket ->
              %Bucket{
                value: bucket.value,
                probability: Fraction.add(partial_bucket.probability, bucket.probability)
              }
            end
          )
        end
      )
      |> Enum.sort_by(&(&1.value))

    %Histogram{
      number_of_dice: number_of_dice,
      buckets: buckets
    }
  end

end
