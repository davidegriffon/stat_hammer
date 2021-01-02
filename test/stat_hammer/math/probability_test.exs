defmodule ProbabilityTest do
  use ExUnit.Case
  alias StatHammer.Math.Fraction
  alias StatHammer.Math.Probability
  alias StatHammer.Phases.HitRoll
  alias StatHammer.Phases.Reroll
  alias StatHammer.Phases.WoundRoll

  describe "probabilty_to_success_n_times/3 bs 2+" do
    probability = HitRoll.probability_to_hit(2)
    # one dice
    assert Probability.probabilty_to_success_n_times(probability, 1, 0) == Fraction.new(1, 6)
    assert Probability.probabilty_to_success_n_times(probability, 1, 1) == Fraction.new(5, 6)
    # two dice
    assert Probability.probabilty_to_success_n_times(probability, 2, 0) == Fraction.new(1, 36)
    assert Probability.probabilty_to_success_n_times(probability, 2, 1) == Fraction.new(5, 18)
    assert Probability.probabilty_to_success_n_times(probability, 2, 2) == Fraction.new(25, 36)
    # three dice
    assert Probability.probabilty_to_success_n_times(probability, 3, 0) == Fraction.new(1, 216)
    assert Probability.probabilty_to_success_n_times(probability, 3, 1) == Fraction.new(15, 216)
    assert Probability.probabilty_to_success_n_times(probability, 3, 2) == Fraction.new(75, 216)
    assert Probability.probabilty_to_success_n_times(probability, 3, 3) == Fraction.new(125, 216)
    # seven dice
    assert Probability.probabilty_to_success_n_times(probability, 7, 0) == Fraction.new(1, 279936)
    # twenty dice
    assert Probability.probabilty_to_success_n_times(probability, 20, 0) == Fraction.new(1, 3656158440062976)
    assert Probability.probabilty_to_success_n_times(probability, 20, 20) == Fraction.new(95367431640625, 3656158440062976)
    # forty dice
    assert Probability.probabilty_to_success_n_times(probability, 40, 0) == Fraction.new(1, 13367494538843734067838845976576)
  end

  describe "probabilty_to_success_n_times/3 bs 3+" do
    probability = HitRoll.probability_to_hit(3)
    # one dice
    assert Probability.probabilty_to_success_n_times(probability, 1, 0) == Fraction.new(2, 6)
    assert Probability.probabilty_to_success_n_times(probability, 1, 1) == Fraction.new(4, 6)
    # two dice
    assert Probability.probabilty_to_success_n_times(probability, 2, 0) == Fraction.new(1, 9)
    assert Probability.probabilty_to_success_n_times(probability, 2, 1) == Fraction.new(4, 9)
    assert Probability.probabilty_to_success_n_times(probability, 2, 2) == Fraction.new(4, 9)
    # three dice
    assert Probability.probabilty_to_success_n_times(probability, 3, 0) == Fraction.new(1, 27)
    assert Probability.probabilty_to_success_n_times(probability, 3, 1) == Fraction.new(6, 27)
    assert Probability.probabilty_to_success_n_times(probability, 3, 2) == Fraction.new(12, 27)
    assert Probability.probabilty_to_success_n_times(probability, 3, 3) == Fraction.new(8, 27)
    # four dice
    assert Probability.probabilty_to_success_n_times(probability, 4, 1) == Fraction.new(8, 81)
    assert Probability.probabilty_to_success_n_times(probability, 4, 2) == Fraction.new(24, 81)
    assert Probability.probabilty_to_success_n_times(probability, 4, 3) == Fraction.new(32, 81)
  end

  describe "probabilty_to_success_n_times/3 bs 4+" do
    probability = HitRoll.probability_to_hit(4)
    # one dice
    assert Probability.probabilty_to_success_n_times(probability, 1, 0) == Fraction.new(1, 2)
    assert Probability.probabilty_to_success_n_times(probability, 1, 1) == Fraction.new(1, 2)
    # six dice
    assert Probability.probabilty_to_success_n_times(probability, 6, 0) == Fraction.new(1, 64)
    assert Probability.probabilty_to_success_n_times(probability, 6, 1) == Fraction.new(6, 64)
    assert Probability.probabilty_to_success_n_times(probability, 6, 2) == Fraction.new(15, 64)
    assert Probability.probabilty_to_success_n_times(probability, 6, 3) == Fraction.new(20, 64)
    assert Probability.probabilty_to_success_n_times(probability, 6, 4) == Fraction.new(15, 64)
    assert Probability.probabilty_to_success_n_times(probability, 6, 5) == Fraction.new(6, 64)
    assert Probability.probabilty_to_success_n_times(probability, 6, 6) == Fraction.new(1, 64)
  end

  describe "probabilty_to_success_n_times/3 bs 5+" do
    probability = HitRoll.probability_to_hit(5)
    # one dice
    assert Probability.probabilty_to_success_n_times(probability, 1, 0) == Fraction.new(4, 6)
    assert Probability.probabilty_to_success_n_times(probability, 1, 1) == Fraction.new(2, 6)
    # four dice
    assert Probability.probabilty_to_success_n_times(probability, 4, 1) == Fraction.new(32, 81)
    assert Probability.probabilty_to_success_n_times(probability, 4, 2) == Fraction.new(24, 81)
    assert Probability.probabilty_to_success_n_times(probability, 4, 3) == Fraction.new(8, 81)
  end

  describe "probabilty_to_success_n_times/3 bs 6+" do
    probability = HitRoll.probability_to_hit(6)
    # one dice
    assert Probability.probabilty_to_success_n_times(probability, 1, 1) == Fraction.new(1, 6)
    assert Probability.probabilty_to_success_n_times(probability, 1, 0) == Fraction.new(5, 6)
    # two dice
    assert Probability.probabilty_to_success_n_times(probability, 2, 2) == Fraction.new(1, 36)
    assert Probability.probabilty_to_success_n_times(probability, 2, 1) == Fraction.new(5, 18)
    assert Probability.probabilty_to_success_n_times(probability, 2, 0) == Fraction.new(25, 36)
    # three dice
    assert Probability.probabilty_to_success_n_times(probability, 3, 3) == Fraction.new(1, 216)
    assert Probability.probabilty_to_success_n_times(probability, 3, 2) == Fraction.new(15, 216)
    assert Probability.probabilty_to_success_n_times(probability, 3, 1) == Fraction.new(75, 216)
    assert Probability.probabilty_to_success_n_times(probability, 3, 0) == Fraction.new(125, 216)
    # seven dice
    assert Probability.probabilty_to_success_n_times(probability, 7, 7) == Fraction.new(1, 279936)
  end

  describe "probabilty_to_success_n_times/4: with scenario probability" do
    p_bs_2 = HitRoll.probability_to_hit(2)
    p_bs_4 = HitRoll.probability_to_hit(4)
    p_bs_6 = HitRoll.probability_to_hit(6)
    assert Probability.probabilty_to_success_n_times(p_bs_2, 3, 3, Fraction.new(2, 3))    == Fraction.multiply(Fraction.new(125, 216), Fraction.new(2, 3))
    assert Probability.probabilty_to_success_n_times(p_bs_4, 6, 3, Fraction.new(34, 76))  == Fraction.multiply(Fraction.new(20, 64), Fraction.new(34, 76))
    assert Probability.probabilty_to_success_n_times(p_bs_4, 6, 4, Fraction.new(4, 16))   == Fraction.multiply(Fraction.new(15, 64), Fraction.new(4, 16))
    assert Probability.probabilty_to_success_n_times(p_bs_4, 6, 5, Fraction.new(26, 9))   == Fraction.multiply(Fraction.new(6, 64), Fraction.new(26, 9))
    assert Probability.probabilty_to_success_n_times(p_bs_6, 3, 3, Fraction.new(34, 35))  == Fraction.multiply(Fraction.new(1, 216), Fraction.new(34, 35))
    assert Probability.probabilty_to_success_n_times(p_bs_6, 3, 2, Fraction.new(55, 334)) == Fraction.multiply(Fraction.new(15, 216), Fraction.new(55, 334))
    assert Probability.probabilty_to_success_n_times(p_bs_6, 3, 1, Fraction.new(2, 67))   == Fraction.multiply(Fraction.new(75, 216), Fraction.new(2, 67))
    assert Probability.probabilty_to_success_n_times(p_bs_6, 3, 0, Fraction.new(25, 333)) == Fraction.multiply(Fraction.new(125, 216), Fraction.new(25, 333))
    assert Probability.probabilty_to_success_n_times(p_bs_6, 7, 7, Fraction.new(44, 99))  == Fraction.multiply(Fraction.new(1, 279936), Fraction.new(44, 99))
  end

  describe "probabiliy_to_roll_one_n_times" do

    test "skill 2+" do
      probability = Reroll.probabiliy_to_roll_one_given_a_miss(2)
      assert Probability.probabilty_to_success_n_times(probability, 1, 1) == Fraction.new(1)
      assert Probability.probabilty_to_success_n_times(probability, 2, 2) == Fraction.new(1)
      assert Probability.probabilty_to_success_n_times(probability, 10, 10) == Fraction.new(1)
      assert Probability.probabilty_to_success_n_times(probability, 2, 1) == Fraction.new(0)
      assert Probability.probabilty_to_success_n_times(probability, 1, 0) == Fraction.new(0)
      assert Probability.probabilty_to_success_n_times(probability, 2, 0) == Fraction.new(0)
      assert Probability.probabilty_to_success_n_times(probability, 10, 0) == Fraction.new(0)
    end

    test "skill 3+" do
      probability = Reroll.probabiliy_to_roll_one_given_a_miss(3)
      assert Probability.probabilty_to_success_n_times(probability, 1, 0) == Fraction.new(1, 2)
      assert Probability.probabilty_to_success_n_times(probability, 1, 1) == Fraction.new(1, 2)
      assert Probability.probabilty_to_success_n_times(probability, 2, 2) == Fraction.new(1, 4)
      assert Probability.probabilty_to_success_n_times(probability, 3, 1) == Fraction.new(3, 8)
    end

    test "skill 4+" do
      probability = Reroll.probabiliy_to_roll_one_given_a_miss(4)
      assert Probability.probabilty_to_success_n_times(probability, 1, 0) == Fraction.new(2, 3)
      assert Probability.probabilty_to_success_n_times(probability, 1, 1) == Fraction.new(1, 3)
      assert Probability.probabilty_to_success_n_times(probability, 2, 2) == Fraction.new(1, 9)
      assert Probability.probabilty_to_success_n_times(probability, 3, 1) == Fraction.new(4, 9)
    end

    test "skill 5+" do
      probability = Reroll.probabiliy_to_roll_one_given_a_miss(5)
      assert Probability.probabilty_to_success_n_times(probability, 1, 0) == Fraction.new(3, 4)
      assert Probability.probabilty_to_success_n_times(probability, 1, 1) == Fraction.new(1, 4)
      assert Probability.probabilty_to_success_n_times(probability, 2, 2) == Fraction.new(1, 16)
      assert Probability.probabilty_to_success_n_times(probability, 3, 2) == Fraction.new(9, 64)
    end

    test "skill 6+" do
      probability = Reroll.probabiliy_to_roll_one_given_a_miss(6)
      assert Probability.probabilty_to_success_n_times(probability, 1, 0) == Fraction.new(4, 5)
      assert Probability.probabilty_to_success_n_times(probability, 1, 1) == Fraction.new(1, 5)
      assert Probability.probabilty_to_success_n_times(probability, 2, 2) == Fraction.new(1, 25)
      assert Probability.probabilty_to_success_n_times(probability, 4, 0) == Fraction.new(256, 625)
      assert Probability.probabilty_to_success_n_times(probability, 4, 1) == Fraction.new(256, 625)
      assert Probability.probabilty_to_success_n_times(probability, 4, 2) == Fraction.new(96, 625)
      assert Probability.probabilty_to_success_n_times(probability, 4, 3) == Fraction.new(16, 625)
      assert Probability.probabilty_to_success_n_times(probability, 4, 4) == Fraction.new(1, 625)
    end

  end

  describe "probabilty_to_wound_n_times" do

    test "strenght 4 and resistance 3" do
      probability = WoundRoll.probability_to_wound(4, 3)
      # one die
      assert Probability.probabilty_to_success_n_times(probability, 1, 1) == Fraction.new(2, 3)
      assert Probability.probabilty_to_success_n_times(probability, 1, 0) == Fraction.new(1, 3)
      # two dice
      assert Probability.probabilty_to_success_n_times(probability, 2, 2) == Fraction.new(4, 9)
    end

    test "strenght 8 and resistance 4" do
      probability = WoundRoll.probability_to_wound(8, 4)
      # one die
      assert Probability.probabilty_to_success_n_times(probability, 1, 1) == Fraction.new(5, 6)
      assert Probability.probabilty_to_success_n_times(probability, 1, 0) == Fraction.new(1, 6)
      # two dice
      assert Probability.probabilty_to_success_n_times(probability, 2, 2) == Fraction.new(25, 36)
      # three dice
      assert Probability.probabilty_to_success_n_times(probability, 3, 2) == Fraction.new(25, 72)
    end

  end

end
