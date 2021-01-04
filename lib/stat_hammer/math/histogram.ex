defmodule StatHammer.Math.Histogram do
  alias StatHammer.Math.Probability
  alias StatHammer.Math.Fraction
  alias StatHammer.Structs.Bucket

  @spec generate(
    Fraction.t(), non_neg_integer(), Fraction.t()
  ) :: list(Bucket.t())
  def generate(
    event_probability, number_of_events, scenario_probability \\ Fraction.new(1)
  )
  def generate(
    event_probability, number_of_events, scenario_probability
  ) do
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
  end

  @spec merge(list(Bucket.t())) :: list(Bucket.t())
  def merge(histogram) do
    histogram
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
  end

end
