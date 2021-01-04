defmodule WoundRollTest do
  use ExUnit.Case
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

end
