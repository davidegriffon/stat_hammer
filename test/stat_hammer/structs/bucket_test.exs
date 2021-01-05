defmodule BucketTest do
  use ExUnit.Case
  alias StatHammer.Math.Fraction
  alias StatHammer.Structs.Bucket
  alias StatHammer.Structs.BucketModifier

  describe "apply_modifier_to_bucket" do

    @tag :bucket
    test "Same bucket value" do
      calculated =
        Bucket.apply_modifier_to_bucket(
          %Bucket{
            value: 2,
            probability: %Fraction{denominator: 3, numerator: 1},
          },
          %BucketModifier{
            bucket_value: 2,
            probability: %Fraction{denominator: 9, numerator: 1},
            type: :add
          }
        )
      expected_result =
        %Bucket{
          value: 2,
          probability: %Fraction{denominator: 9, numerator: 4},
        }
      assert expected_result == calculated
    end

    @tag :bucket
    test "Different bucket value" do
      bucket =
        %Bucket{
          value: 2,
          probability: %Fraction{denominator: 144, numerator: 3},
        }
      calculated =
        Bucket.apply_modifier_to_bucket(
          bucket,
          %BucketModifier{
            bucket_value: 3,
            probability: %Fraction{denominator: 9, numerator: 1},
            type: :add
          }
        )
      # bucket does not change
      assert bucket == calculated
    end

  end

  describe "apply_modifiers_to_bucket" do

    @tag :bucket
    test "Case 1" do
      modifiers = [
        %BucketModifier{
          bucket_value: 1,
          probability: Fraction.new(1, 9),
          type: :add
        },
        %BucketModifier{
          bucket_value: 2,
          probability: Fraction.new(5, 7),
          type: :add
        },
        %BucketModifier{
          bucket_value: 1,
          probability: Fraction.new(6, 9),
          type: :add
        }
      ]
      calculated =
        Bucket.apply_modifiers_to_bucket(
          %Bucket{
            value: 1,
            probability: Fraction.new(1, 9),
          },
          modifiers
        )
      expected_result =
        %Bucket{
          value: 1,
          probability: Fraction.new(8, 9),
        }
      assert expected_result == calculated
    end

  end

end
