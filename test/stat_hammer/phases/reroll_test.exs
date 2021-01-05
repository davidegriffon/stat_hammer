defmodule ReRollTest do
  use ExUnit.Case
  alias StatHammer.Math.Fraction
  alias StatHammer.Phases.HitRoll
  alias StatHammer.Phases.Reroll
  alias StatHammer.Structs.Defense
  alias StatHammer.Structs.Attack
  alias StatHammer.Structs.Attack.HitModifiers
  alias StatHammer.Structs.Attack.WoundModifiers
  alias StatHammer.Structs.Bucket
  alias StatHammer.Structs.BucketModifier
  alias StatHammer.Structs.SecondChance
  alias StatHammer.App

  describe "modifiers_of_second_chance" do

    @tag :reroll_phase
    test "one die to reroll" do
      original_bucket = %Bucket{value: 2, probability: Fraction.new(1)}
      hit_probability_with_bs_3 = HitRoll.probability_to_hit(3)
      result = Reroll.modifiers_of_second_chance(
        %SecondChance{
          number_of_dice: 1,
          probability: Fraction.new(1, 2),
          original_bucket: original_bucket
        },
        hit_probability_with_bs_3
      )
      expected = [
        %BucketModifier{
          bucket_value: 3,
          probability: Fraction.new(1, 3),
          type: :add,
          original_bucket: original_bucket
        }
      ]
      assert result == expected
    end

    @tag :reroll_phase
    test "two dice to reroll" do
      original_bucket = %Bucket{value: 1, probability: Fraction.new(2, 9)}
      hit_probability_with_bs_3 = HitRoll.probability_to_hit(3)
      result = Reroll.modifiers_of_second_chance(
        %SecondChance{
          number_of_dice: 2,
          probability: Fraction.new(1, 4),
          original_bucket: original_bucket,
        },
        hit_probability_with_bs_3
      )
      expected = [
        %BucketModifier{bucket_value: 2, probability: Fraction.new(1, 9), type: :add, original_bucket: original_bucket},
        %BucketModifier{bucket_value: 3, probability: Fraction.new(1, 9), type: :add, original_bucket: original_bucket},
      ]
      assert result == expected
    end

    @tag :reroll_phase
    test "three dice to reroll" do
      original_bucket = %Bucket{value: 0, probability: Fraction.new(1, 27)}
      hit_probability_with_bs_3 = HitRoll.probability_to_hit(3)
      result = Reroll.modifiers_of_second_chance(
        %SecondChance{number_of_dice: 3, probability: Fraction.new(1, 8), original_bucket: original_bucket},
        hit_probability_with_bs_3
      )
      expected = [
        %BucketModifier{bucket_value: 1, probability: Fraction.new(1, 36), type: :add, original_bucket: original_bucket},
        %BucketModifier{bucket_value: 2, probability: Fraction.new(1, 18), type: :add, original_bucket: original_bucket},
        %BucketModifier{bucket_value: 3, probability: Fraction.new(1, 27), type: :add, original_bucket: original_bucket},
      ]
      assert result == expected
    end

    @tag :reroll_phase
    test "many dice to reroll" do
      original_bucket = %Bucket{value: 0, probability: Fraction.new(1)}
      hit_probability_with_bs_3 = HitRoll.probability_to_hit(3)
      result = Reroll.modifiers_of_second_chance(
        %SecondChance{number_of_dice: 50, probability: Fraction.new(1), original_bucket: original_bucket},
        hit_probability_with_bs_3
      )
      assert Fraction.pow(Fraction.new(2, 3), 50) == Enum.at(result, -1).probability
    end

  end

  describe "modifiers_of_bucket" do

    @tag :reroll_phase
    test "Hit phase" do
      attack = %Attack{
        number_of_dice: 3,
        skill: 3,
        strenght: 4,
        armor_penetration: 0,
        hit_modifiers: %HitModifiers{
          reroll: :reroll_ones,
          on_six: :on_six_none,
        },
        wound_modifiers: %WoundModifiers{
          reroll: :reroll_ones,
          on_six: :on_six_none,
        },
      }
      simulation = App.create_simulation(attack, %Defense{})
      calculated_modifiers =
        Reroll.modifiers_of_bucket(
          %Bucket{value: 0, probability: Fraction.new(1)},
          simulation,
          :hit_phase
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

  describe "modifiers_of_simulation" do

    test "Hit Phase" do
      attack = %Attack{
        number_of_dice: 3,
        skill: 3,
        strenght: 4,
        armor_penetration: 0,
        hit_modifiers: %HitModifiers{
          reroll: :reroll_ones,
          on_six: :on_six_none,
        },
        wound_modifiers: %WoundModifiers{
          reroll: :reroll_none,
          on_six: :on_six_none,
        },
      }
      simulation =
        App.create_simulation(attack, %Defense{})
        |> HitRoll.simulate()
        |> Reroll.simulate()

      calculated_modifiers = simulation.meta.hit_reroll_modifiers

      bucket_0_probability = Fraction.new(1, 27)
      bucket_1_probability = Fraction.new(6, 27)
      bucket_2_probability = Fraction.new(12, 27)
      expected_modifiers = [
        # bucket 0
        %BucketModifier{
          bucket_value: 0,
          probability: Fraction.multiply(Fraction.new(19, 27), bucket_0_probability),
          type: :subtraction
        },
        %BucketModifier{
          bucket_value: 1,
          probability: Fraction.multiply(Fraction.new(1, 4), bucket_0_probability),
          type: :add
        },
        %BucketModifier{
          bucket_value: 1,
          probability: Fraction.multiply(Fraction.new(1, 6), bucket_0_probability),
          type: :add
        },
        %BucketModifier{
          bucket_value: 2,
          probability: Fraction.multiply(Fraction.new(1, 6), bucket_0_probability),
          type: :add
        },
        %BucketModifier{
          bucket_value: 1,
          probability: Fraction.multiply(Fraction.new(1, 36), bucket_0_probability),
          type: :add
        },
        %BucketModifier{
          bucket_value: 2,
          probability: Fraction.multiply(Fraction.new(1, 18), bucket_0_probability),
          type: :add
        },
        %BucketModifier{
          bucket_value: 3,
          probability: Fraction.multiply(Fraction.new(1, 27), bucket_0_probability),
          type: :add
        },
        # bucket 1
        %BucketModifier{
          bucket_value: 1,
          probability: Fraction.multiply(Fraction.new(5, 9), bucket_1_probability),
          type: :subtraction
        },
        %BucketModifier{
          bucket_value: 2,
          probability: Fraction.multiply(Fraction.new(1, 3), bucket_1_probability),
          type: :add
        },
        %BucketModifier{
          bucket_value: 2,
          probability: Fraction.multiply(Fraction.new(1, 9), bucket_1_probability),
          type: :add
        },
        %BucketModifier{
          bucket_value: 3,
          probability: Fraction.multiply(Fraction.new(1, 9), bucket_1_probability),
          type: :add
        },
        # bucket 2
        %BucketModifier{
          bucket_value: 2,
          probability: Fraction.multiply(Fraction.new(1, 3), bucket_2_probability),
          type: :subtraction
        },
        %BucketModifier{
          bucket_value: 3,
          probability: Fraction.multiply(Fraction.new(1, 3), bucket_2_probability),
          type: :add
        },
      ]

      assert expected_modifiers == calculated_modifiers

      # check that the sum is zero
      sum =
        Enum.reduce(
          calculated_modifiers,
          Fraction.new(0),
          fn modifier, acc ->
            case modifier.type do
              :add -> Fraction.add(acc, modifier.probability)
              :subtraction -> Fraction.subtraction(acc, modifier.probability)
            end
          end
        )
      assert sum == Fraction.new(0)
    end

  end

end
