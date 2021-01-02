defmodule WoundRollTest do
  use ExUnit.Case
  alias StatHammer.Structs.Bucket
  alias StatHammer.Math.Fraction
  alias StatHammer.Phases.WoundRoll

  describe "probability_to_wound" do

    test "case 1" do
      assert WoundRoll.probability_to_wound(3, 3) == Fraction.new(1, 2)
      assert WoundRoll.probability_to_wound(4, 4) == Fraction.new(1, 2)
      assert WoundRoll.probability_to_wound(8, 8) == Fraction.new(1, 2)
      assert WoundRoll.probability_to_wound(8, 7) == Fraction.new(2, 3)
      assert WoundRoll.probability_to_wound(6, 3) == Fraction.new(5, 6)
      assert WoundRoll.probability_to_wound(4, 3) == Fraction.new(4, 6)
    end

  end

  describe "sub_histogram_of_bucket" do

    test "case 1" do
      parent_bucket_probability = Fraction.new(1, 2)
      parent_bucket = %Bucket{
        value: 2,
        probability: parent_bucket_probability,
      }
      calculated_result = WoundRoll.sub_histogram_of_bucket(parent_bucket, 4, 4)
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
      calculated_result = WoundRoll.merge(buckets)
      assert expected_result == calculated_result
    end

  end

end
