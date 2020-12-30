defmodule ReRollTest do
  use ExUnit.Case
  alias StatHammer.Math.Fraction
  alias StatHammer.Phases.HitRoll
  alias StatHammer.Phases.Reroll
  alias StatHammer.Structs.Defense
  alias StatHammer.Structs.Attack
  alias StatHammer.Structs.Attack.HitModifiers
  alias StatHammer.Structs.Bucket
  alias StatHammer.Structs.BucketModifier
  alias StatHammer.Structs.SecondChance
  alias StatHammer.App

  describe "probabiliy_to_roll_one_n_times" do

    test "skill 2+" do
      assert Reroll.probabiliy_to_roll_one_n_times(2, 1, 1) == Fraction.new(1)
      assert Reroll.probabiliy_to_roll_one_n_times(2, 2, 2) == Fraction.new(1)
      assert Reroll.probabiliy_to_roll_one_n_times(2, 10, 10) == Fraction.new(1)
      assert Reroll.probabiliy_to_roll_one_n_times(2, 2, 1) == Fraction.new(0)
      assert Reroll.probabiliy_to_roll_one_n_times(2, 1, 0) == Fraction.new(0)
      assert Reroll.probabiliy_to_roll_one_n_times(2, 2, 0) == Fraction.new(0)
      assert Reroll.probabiliy_to_roll_one_n_times(2, 10, 0) == Fraction.new(0)
    end

    test "skill 3+" do
      assert Reroll.probabiliy_to_roll_one_n_times(3, 1, 0) == Fraction.new(1, 2)
      assert Reroll.probabiliy_to_roll_one_n_times(3, 1, 1) == Fraction.new(1, 2)
      assert Reroll.probabiliy_to_roll_one_n_times(3, 2, 2) == Fraction.new(1, 4)
      assert Reroll.probabiliy_to_roll_one_n_times(3, 3, 1) == Fraction.new(3, 8)
    end

    test "skill 4+" do
      assert Reroll.probabiliy_to_roll_one_n_times(4, 1, 0) == Fraction.new(2, 3)
      assert Reroll.probabiliy_to_roll_one_n_times(4, 1, 1) == Fraction.new(1, 3)
      assert Reroll.probabiliy_to_roll_one_n_times(4, 2, 2) == Fraction.new(1, 9)
      assert Reroll.probabiliy_to_roll_one_n_times(4, 3, 1) == Fraction.new(4, 9)
    end

    test "skill 5+" do
      assert Reroll.probabiliy_to_roll_one_n_times(5, 1, 0) == Fraction.new(3, 4)
      assert Reroll.probabiliy_to_roll_one_n_times(5, 1, 1) == Fraction.new(1, 4)
      assert Reroll.probabiliy_to_roll_one_n_times(5, 2, 2) == Fraction.new(1, 16)
      assert Reroll.probabiliy_to_roll_one_n_times(5, 3, 2) == Fraction.new(9, 64)
    end

    test "skill 6+" do
      assert Reroll.probabiliy_to_roll_one_n_times(6, 1, 0) == Fraction.new(4, 5)
      assert Reroll.probabiliy_to_roll_one_n_times(6, 1, 1) == Fraction.new(1, 5)
      assert Reroll.probabiliy_to_roll_one_n_times(6, 2, 2) == Fraction.new(1, 25)
      assert Reroll.probabiliy_to_roll_one_n_times(6, 4, 0) == Fraction.new(256, 625)
      assert Reroll.probabiliy_to_roll_one_n_times(6, 4, 1) == Fraction.new(256, 625)
      assert Reroll.probabiliy_to_roll_one_n_times(6, 4, 2) == Fraction.new(96, 625)
      assert Reroll.probabiliy_to_roll_one_n_times(6, 4, 3) == Fraction.new(16, 625)
      assert Reroll.probabiliy_to_roll_one_n_times(6, 4, 4) == Fraction.new(1, 625)
    end

  end

  defp check_sum_of_probabilities_of_second_chances(second_chances) do
    sum_of_probabilities =
      Enum.reduce(
        second_chances,
        Fraction.new(0),
        fn chance, acc -> Fraction.add(chance.probability, acc) end
      )
    assert sum_of_probabilities == Fraction.new(1)
  end

  describe "get_second_chances" do
    # note that the most important logic of this function is in the
    # `probabiliy_to_roll_one_n_times` funciont, that is already tested above

    test "the sum of probabilities is always 1" do
      combinations = for skill <- 2..6, number_of_fails <- 1..10 do {skill, number_of_fails} end
      Enum.each(
        combinations,
        fn {skill, number_of_fails} ->
          Reroll.get_second_chances(skill, number_of_fails, :reroll_ones)
          |> check_sum_of_probabilities_of_second_chances()
        end
      )
    end

    test "reroll_ones type" do
      assert Reroll.get_second_chances(3, 1, :reroll_ones) ==
        [
          %SecondChance{number_of_dice: 0, probability: Fraction.new(1, 2)},
          %SecondChance{number_of_dice: 1, probability: Fraction.new(1, 2)},
        ]
      assert Reroll.get_second_chances(3, 2, :reroll_ones) ==
        [
          %SecondChance{number_of_dice: 0, probability: Fraction.new(1, 4)},
          %SecondChance{number_of_dice: 1, probability: Fraction.new(1, 2)},
          %SecondChance{number_of_dice: 2, probability: Fraction.new(1, 4)},
        ]
      assert Reroll.get_second_chances(3, 3, :reroll_ones) ==
        [
          %SecondChance{number_of_dice: 0, probability: Fraction.new(1, 8)},
          %SecondChance{number_of_dice: 1, probability: Fraction.new(3, 8)},
          %SecondChance{number_of_dice: 2, probability: Fraction.new(3, 8)},
          %SecondChance{number_of_dice: 3, probability: Fraction.new(1, 8)},
        ]
      assert Reroll.get_second_chances(4, 2, :reroll_ones) ==
        [
          %SecondChance{number_of_dice: 0, probability: Fraction.new(4, 9)},
          %SecondChance{number_of_dice: 1, probability: Fraction.new(4, 9)},
          %SecondChance{number_of_dice: 2, probability: Fraction.new(1, 9)},
        ]
    end

    test "reroll_all type" do
      assert Reroll.get_second_chances(3, 3, :reroll_all) == [%SecondChance{number_of_dice: 3, probability: Fraction.new(1)}]
      assert Reroll.get_second_chances(4, 6, :reroll_all) == [%SecondChance{number_of_dice: 6, probability: Fraction.new(1)}]
      assert Reroll.get_second_chances(5, 9, :reroll_all) == [%SecondChance{number_of_dice: 9, probability: Fraction.new(1)}]
      assert Reroll.get_second_chances(6, 2, :reroll_all) == [%SecondChance{number_of_dice: 2, probability: Fraction.new(1)}]
    end

  end

  describe "bucket_modifiers_of_second_chance" do

    test "one die" do
      result = Reroll.bucket_modifiers_of_second_chance(
        %SecondChance{number_of_dice: 1, probability: Fraction.new(1, 2)},
        3,
        %Bucket{value: 2, probability: Fraction.new(12, 27)}
      )
      expected = [%BucketModifier{bucket_value: 3, probability: Fraction.new(1, 3), type: :add}]
      assert result == expected
    end

    test "two dice" do
      result = Reroll.bucket_modifiers_of_second_chance(
        %SecondChance{number_of_dice: 2, probability: Fraction.new(1, 4)},
        3,
        %Bucket{value: 1, probability: Fraction.new(2, 9)}
      )
      expected = [
        %BucketModifier{bucket_value: 2, probability: Fraction.new(1, 9), type: :add},
        %BucketModifier{bucket_value: 3, probability: Fraction.new(1, 9), type: :add},
      ]
      assert result == expected
    end

    test "three dice" do
      result = Reroll.bucket_modifiers_of_second_chance(
        %SecondChance{number_of_dice: 3, probability: Fraction.new(1, 8)},
        3,
        %Bucket{value: 0, probability: Fraction.new(1, 27)}
      )
      expected = [
        %BucketModifier{bucket_value: 1, probability: Fraction.new(1, 36), type: :add},
        %BucketModifier{bucket_value: 2, probability: Fraction.new(1, 18), type: :add},
        %BucketModifier{bucket_value: 3, probability: Fraction.new(1, 27), type: :add},
      ]
      assert result == expected
    end

    test "many dice" do
      result = Reroll.bucket_modifiers_of_second_chance(
        %SecondChance{number_of_dice: 50, probability: Fraction.new(1)},
        3,
        %Bucket{value: 0, probability: Fraction.new(1)}
      )
      assert Fraction.pow(Fraction.new(2, 3), 50) == Enum.at(result, -1).probability
    end

  end

  describe "bucket_modifiers_of_bucket" do

    test "case 1" do
      attack = %Attack{
        number_of_dice: 3,
        skill: 3,
        strenght: 4,
        armor_penetration: 0,
        hit_modifiers: %HitModifiers{
          reroll: :reroll_ones,
          on_six: :on_six_none,
        }
      }
      simulation = App.create_simulation(attack, %Defense{})
      calculated_modifiers = Reroll.bucket_modifiers_of_bucket(
        %Bucket{value: 0, probability: Fraction.new(1)},
        simulation
      )
      expected_modifiers = [
        %BucketModifier{
          bucket_value: 0,
          probability: %Fraction{denominator: 27, numerator: 19},
          type: :subtraction
        },
        %BucketModifier{
          bucket_value: 1,
          probability: %Fraction{denominator: 4, numerator: 1},
          type: :add
        },
        %BucketModifier{
          bucket_value: 1,
          probability: %Fraction{denominator: 6, numerator: 1},
          type: :add
        },
        %BucketModifier{
          bucket_value: 2,
          probability: %Fraction{denominator: 6, numerator: 1},
          type: :add
        },
        %BucketModifier{
          bucket_value: 1,
          probability: %Fraction{denominator: 36, numerator: 1},
          type: :add
        },
        %BucketModifier{
          bucket_value: 2,
          probability: %Fraction{denominator: 18, numerator: 1},
          type: :add
        },
        %BucketModifier{
          bucket_value: 3,
          probability: %Fraction{denominator: 27, numerator: 1},
          type: :add
        }
      ]
      assert expected_modifiers == calculated_modifiers
    end

  end

  describe "nah" do

    test "foo" do
      attack = %Attack{
        number_of_dice: 2,
        skill: 4,
        strenght: 4,
        armor_penetration: 0,
        hit_modifiers: %HitModifiers{
          reroll: :reroll_ones,
          on_six: :on_six_none,
        }
      }
      simulation =
        App.create_simulation(attack, %Defense{})
        |> HitRoll.apply()
        |> Reroll.apply()
      #IO.warn "::: #{inspect(simulation)}"
    end

  end

end
