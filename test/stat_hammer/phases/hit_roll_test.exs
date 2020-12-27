defmodule HitRollTest do
  use ExUnit.Case
  alias StatHammer.Math.Fraction
  alias StatHammer.Phases.HitRoll

  describe "to hit" do

    test "valid input" do
      assert HitRoll.probability_to_hit(2) == Fraction.new(5, 6)
      assert HitRoll.probability_to_hit(3) == Fraction.new(4, 6)
    end

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

  describe "probabilty_to_hit_n_times bs 2+" do
    # one dice
    assert HitRoll.probabilty_to_hit_n_times(2, 1, 0) == Fraction.new(1, 6)
    assert HitRoll.probabilty_to_hit_n_times(2, 1, 1) == Fraction.new(5, 6)
    # two dice
    assert HitRoll.probabilty_to_hit_n_times(2, 2, 0) == Fraction.new(1, 36)
    assert HitRoll.probabilty_to_hit_n_times(2, 2, 1) == Fraction.new(5, 18)
    assert HitRoll.probabilty_to_hit_n_times(2, 2, 2) == Fraction.new(25, 36)
    # three dice
    assert HitRoll.probabilty_to_hit_n_times(2, 3, 0) == Fraction.new(1, 216)
    assert HitRoll.probabilty_to_hit_n_times(2, 3, 1) == Fraction.new(15, 216)
    assert HitRoll.probabilty_to_hit_n_times(2, 3, 2) == Fraction.new(75, 216)
    assert HitRoll.probabilty_to_hit_n_times(2, 3, 3) == Fraction.new(125, 216)
    # seven dice
    assert HitRoll.probabilty_to_hit_n_times(2, 7, 0) == Fraction.new(1, 279936)
    # twenty dice
    assert HitRoll.probabilty_to_hit_n_times(2, 20, 0) == Fraction.new(1, 3656158440062976)
    assert HitRoll.probabilty_to_hit_n_times(2, 20, 20) == Fraction.new(95367431640625, 3656158440062976)
    # forty dice
    assert HitRoll.probabilty_to_hit_n_times(2, 40, 0) == Fraction.new(1, 13367494538843734067838845976576)
  end

  describe "probabilty_to_hit_n_times bs 3+" do
    # one dice
    assert HitRoll.probabilty_to_hit_n_times(3, 1, 0) == Fraction.new(2, 6)
    assert HitRoll.probabilty_to_hit_n_times(3, 1, 1) == Fraction.new(4, 6)
    # four dice
    assert HitRoll.probabilty_to_hit_n_times(3, 4, 1) == Fraction.new(8, 81)
    assert HitRoll.probabilty_to_hit_n_times(3, 4, 2) == Fraction.new(24, 81)
    assert HitRoll.probabilty_to_hit_n_times(3, 4, 3) == Fraction.new(32, 81)
  end

  describe "probabilty_to_hit_n_times bs 4+" do
    # one dice
    assert HitRoll.probabilty_to_hit_n_times(4, 1, 0) == Fraction.new(1, 2)
    assert HitRoll.probabilty_to_hit_n_times(4, 1, 1) == Fraction.new(1, 2)
    # six dice
    assert HitRoll.probabilty_to_hit_n_times(4, 6, 0) == Fraction.new(1, 64)
    assert HitRoll.probabilty_to_hit_n_times(4, 6, 1) == Fraction.new(6, 64)
    assert HitRoll.probabilty_to_hit_n_times(4, 6, 2) == Fraction.new(15, 64)
    assert HitRoll.probabilty_to_hit_n_times(4, 6, 3) == Fraction.new(20, 64)
    assert HitRoll.probabilty_to_hit_n_times(4, 6, 4) == Fraction.new(15, 64)
    assert HitRoll.probabilty_to_hit_n_times(4, 6, 5) == Fraction.new(6, 64)
    assert HitRoll.probabilty_to_hit_n_times(4, 6, 6) == Fraction.new(1, 64)
  end

  describe "probabilty_to_hit_n_times bs 5+" do
    # one dice
    assert HitRoll.probabilty_to_hit_n_times(5, 1, 0) == Fraction.new(4, 6)
    assert HitRoll.probabilty_to_hit_n_times(5, 1, 1) == Fraction.new(2, 6)
    # four dice
    assert HitRoll.probabilty_to_hit_n_times(5, 4, 1) == Fraction.new(32, 81)
    assert HitRoll.probabilty_to_hit_n_times(5, 4, 2) == Fraction.new(24, 81)
    assert HitRoll.probabilty_to_hit_n_times(5, 4, 3) == Fraction.new(8, 81)
  end

  describe "probabilty_to_hit_n_times bs 6+" do
    # one dice
    assert HitRoll.probabilty_to_hit_n_times(6, 1, 1) == Fraction.new(1, 6)
    assert HitRoll.probabilty_to_hit_n_times(6, 1, 0) == Fraction.new(5, 6)
    # two dice
    assert HitRoll.probabilty_to_hit_n_times(6, 2, 2) == Fraction.new(1, 36)
    assert HitRoll.probabilty_to_hit_n_times(6, 2, 1) == Fraction.new(5, 18)
    assert HitRoll.probabilty_to_hit_n_times(6, 2, 0) == Fraction.new(25, 36)
    # three dice
    assert HitRoll.probabilty_to_hit_n_times(6, 3, 3) == Fraction.new(1, 216)
    assert HitRoll.probabilty_to_hit_n_times(6, 3, 2) == Fraction.new(15, 216)
    assert HitRoll.probabilty_to_hit_n_times(6, 3, 1) == Fraction.new(75, 216)
    assert HitRoll.probabilty_to_hit_n_times(6, 3, 0) == Fraction.new(125, 216)
    # seven dice
    assert HitRoll.probabilty_to_hit_n_times(6, 7, 7) == Fraction.new(1, 279936)
  end

  test "probability_to_hit/2" do
    assert HitRoll.probability_to_hit(2, 3) == [
      {0, Fraction.new(1, 216)},
      {1, Fraction.new(15, 216)},
      {2, Fraction.new(75, 216)},
      {3, Fraction.new(125, 216)},
    ]
  end

end
