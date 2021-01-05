defmodule SecondChanceTest do
  use ExUnit.Case
  alias StatHammer.Math.Fraction
  alias StatHammer.Structs.Histogram
  alias StatHammer.Phases.HitRoll
  alias StatHammer.Structs.Bucket
  alias StatHammer.Structs.SecondChance

  defp check_sum_of_probabilities_of_second_chances(second_chances) do
    sum_of_probabilities =
      Enum.reduce(
        second_chances,
        Fraction.new(0),
        fn chance, acc -> Fraction.add(chance.probability, acc) end
      )
    assert sum_of_probabilities == Fraction.new(1)
  end

  describe "second_chances/3" do

    @tag :second_chance
    test "the sum of probabilities is always 1" do
      combinations =
        for skill <- 2..6, number_of_fails <- 1..10 do {skill, number_of_fails} end

      Enum.each(
        combinations,
        fn {skill, number_of_fails} ->
          original_bucket =
            %Bucket{
              value: number_of_fails,
              probability: Fraction.new(1)
            }
          SecondChance.second_chances(
            HitRoll.probability_to_roll_one_given_a_miss(skill),
            number_of_fails,
            :reroll_ones,
            original_bucket
          )
          |> check_sum_of_probabilities_of_second_chances()
        end
      )
    end

    @tag :second_chance
    test "reroll_ones type" do

      probabiliy_bs_3 = HitRoll.probability_to_roll_one_given_a_miss(3)
      probabiliy_bs_4 = HitRoll.probability_to_roll_one_given_a_miss(4)

      ob_2 = %Bucket{value: 2, probability: Fraction.new(1)}
      ob_3 = %Bucket{value: 3, probability: Fraction.new(1)}

      assert SecondChance.second_chances(probabiliy_bs_3, 1, :reroll_ones, ob_2) ==
        [
          %SecondChance{number_of_dice: 0, probability: Fraction.new(1, 2), original_bucket: ob_2},
          %SecondChance{number_of_dice: 1, probability: Fraction.new(1, 2), original_bucket: ob_2},
        ]

      assert SecondChance.second_chances(probabiliy_bs_3, 2, :reroll_ones, ob_3) ==
        [
          %SecondChance{number_of_dice: 0, probability: Fraction.new(1, 4), original_bucket: ob_3},
          %SecondChance{number_of_dice: 1, probability: Fraction.new(1, 2), original_bucket: ob_3},
          %SecondChance{number_of_dice: 2, probability: Fraction.new(1, 4), original_bucket: ob_3},
        ]

      assert SecondChance.second_chances(probabiliy_bs_3, 3, :reroll_ones, ob_3) ==
        [
          %SecondChance{number_of_dice: 0, probability: Fraction.new(1, 8), original_bucket: ob_3},
          %SecondChance{number_of_dice: 1, probability: Fraction.new(3, 8), original_bucket: ob_3},
          %SecondChance{number_of_dice: 2, probability: Fraction.new(3, 8), original_bucket: ob_3},
          %SecondChance{number_of_dice: 3, probability: Fraction.new(1, 8), original_bucket: ob_3},
        ]

      assert SecondChance.second_chances(probabiliy_bs_4, 2, :reroll_ones, ob_2) ==
        [
          %SecondChance{number_of_dice: 0, probability: Fraction.new(4, 9), original_bucket: ob_2},
          %SecondChance{number_of_dice: 1, probability: Fraction.new(4, 9), original_bucket: ob_2},
          %SecondChance{number_of_dice: 2, probability: Fraction.new(1, 9), original_bucket: ob_2},
        ]
    end

    @tag :second_chance
    test "reroll_all type" do
      check = fn skill, number_of_fails ->
        original_bucket = %Bucket{value: 2, probability: Fraction.new(1)}
        assert SecondChance.second_chances(
          HitRoll.probability_to_roll_one_given_a_miss(skill), number_of_fails, :reroll_all, original_bucket
        ) == [%SecondChance{number_of_dice: number_of_fails, probability: Fraction.new(1), original_bucket: original_bucket}]
      end
      check.(2, 3)
      check.(3, 3)
      check.(4, 6)
      check.(5, 9)
      check.(6, 2)
      check.(6, 20)
    end

  end

  describe "second_chances_of_histogram/3" do

    @tag :second_chance
    test "Case 1" do
      probability_to_hit = HitRoll.probability_to_hit(3)
      probability_to_roll_one = HitRoll.probability_to_roll_one_given_a_miss(3)
      histogram = Histogram.generate(probability_to_hit, 3)
      calculated_chances = SecondChance.second_chances_of_histogram(
        histogram,
        probability_to_roll_one,
        :reroll_ones
      )
      expected_chances = [
        %SecondChance{
          number_of_dice: 1,
          original_bucket: %Bucket{
            probability: %Fraction{denominator: 27, numerator: 1},
            value: 0
          },
          probability: %Fraction{denominator: 72, numerator: 1}
        },
        %SecondChance{
          number_of_dice: 2,
          original_bucket: %Bucket{
            probability: %Fraction{denominator: 27, numerator: 1},
            value: 0
          },
          probability: %Fraction{denominator: 72, numerator: 1}
        },
        %SecondChance{
          number_of_dice: 3,
          original_bucket: %Bucket{
            probability: %Fraction{denominator: 27, numerator: 1},
            value: 0
          },
          probability: %Fraction{denominator: 216, numerator: 1}
        },
        %SecondChance{
          number_of_dice: 1,
          original_bucket: %Bucket{
            probability: %Fraction{denominator: 9, numerator: 2},
            value: 1
          },
          probability: %Fraction{denominator: 9, numerator: 1}
        },
        %SecondChance{
          number_of_dice: 2,
          original_bucket: %Bucket{
            probability: %Fraction{denominator: 9, numerator: 2},
            value: 1
          },
          probability: %Fraction{denominator: 18, numerator: 1}
        },
        %SecondChance{
          number_of_dice: 1,
          original_bucket: %Bucket{
            probability: %Fraction{denominator: 9, numerator: 4},
            value: 2
          },
          probability: %Fraction{denominator: 9, numerator: 2}
        }
      ]
      assert calculated_chances == expected_chances
    end

  end

end
