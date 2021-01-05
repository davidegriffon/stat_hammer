defmodule HitRollTest do
  use ExUnit.Case
  alias StatHammer.Math.Fraction
  alias StatHammer.Structs.Histogram
  alias StatHammer.Phases.HitRoll
  alias StatHammer.Structs.Bucket

  describe "probability_to_hit/2" do

    @tag :hit_phase
    test "valid input" do
      assert HitRoll.probability_to_hit(2) == Fraction.new(5, 6)
      assert HitRoll.probability_to_hit(3) == Fraction.new(4, 6)
    end

    @tag :hit_phase
    test "wrong input" do
      assert_raise ArgumentError, fn ->
        HitRoll.probability_to_hit(1)
      end
      assert_raise ArgumentError, fn ->
        HitRoll.probability_to_hit(7)
      end
      assert_raise ArgumentError, fn ->
        HitRoll.probability_to_hit(2.1)
      end
    end

  end

  describe "histogram/2" do

    @tag :hit_phase
    test "Case 1" do
      probability_to_hit = HitRoll.probability_to_hit(2)
      assert Histogram.generate(probability_to_hit, 3) ==
        %Histogram{
          number_of_dice: 3,
          buckets: [
            Bucket.from_tuple({0, Fraction.new(1, 216)}),
            Bucket.from_tuple({1, Fraction.new(15, 216)}),
            Bucket.from_tuple({2, Fraction.new(75, 216)}),
            Bucket.from_tuple({3, Fraction.new(125, 216)}),
          ]
        }
    end

  end

end
