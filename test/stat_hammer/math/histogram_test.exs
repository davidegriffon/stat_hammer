defmodule HistogramTest do
  use ExUnit.Case
  alias StatHammer.Math.Histogram
  alias StatHammer.Math.Fraction
  alias StatHammer.Structs.Bucket

  describe "generate/3" do

    test "case 1" do
      event_probability = Fraction.new(1, 2)
      parent_probability = Fraction.new(1, 2)
      calculated_result = Histogram.generate(event_probability, 2, parent_probability)
      expected_result = [
        %Bucket{
          probability: %Fraction{denominator: 8, numerator: 1},
          value: 0
        },
        %Bucket{
          probability: %Fraction{denominator: 4, numerator: 1},
          value: 1
        },
        %Bucket{
          probability: %Fraction{denominator: 8, numerator: 1},
          value: 2
        }
      ]
      assert calculated_result == expected_result
    end

  end

  describe "merge" do

    test "case 1" do
      buckets = [
        %Bucket{
          value: 2,
          probability: Fraction.new(1, 8),
        },
        %Bucket{
          value: 0,
          probability: Fraction.new(1, 3),
        },
        %Bucket{
          value: 0,
          probability: Fraction.new(2, 5),
        },
        %Bucket{
          value: 1,
          probability: Fraction.new(4, 9),
        },
        %Bucket{
          value: 2,
          probability: Fraction.new(7, 16),
        },
        %Bucket{
          value: 3,
          probability: Fraction.new(4, 5),
        },
        %Bucket{
          value: 4,
          probability: Fraction.new(9, 13),
        },
      ]
      expected_result = [
        %Bucket{
          value: 0,
          probability: Fraction.new(11, 15),
        },
        %Bucket{
          value: 1,
          probability: Fraction.new(4, 9),
        },
        %Bucket{
          value: 2,
          probability: Fraction.new(9, 16),
        },
        %Bucket{
          value: 3,
          probability: Fraction.new(4, 5),
        },
        %Bucket{
          value: 4,
          probability: Fraction.new(9, 13),
        },
      ]
      calculated_result = Histogram.merge(buckets)
      assert expected_result == calculated_result
    end

  end

end
