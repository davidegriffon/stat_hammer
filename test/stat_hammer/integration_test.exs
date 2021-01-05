defmodule IntegrationTest do
  use ExUnit.Case
  alias StatHammer.Math.Fraction
  alias StatHammer.Phases.HitRoll
  alias StatHammer.Phases.WoundRoll
  alias StatHammer.Phases.Reroll
  alias StatHammer.Structs.Defense
  alias StatHammer.Structs.Attack
  alias StatHammer.Structs.Attack.HitModifiers
  alias StatHammer.Structs.Attack.WoundModifiers
  alias StatHammer.App

  def cumulated(nil) do
    "-"
  end
  def cumulated(histogram) do
    Enum.with_index(histogram)
    |> Enum.map(
      fn {_bucket, index} ->
        prob =
          Enum.reduce(
            Enum.take(histogram, - index - 1),
            Fraction.new(0),
            fn bucket, acc ->
              Fraction.add(bucket.probability, acc)
            end
          )
        "#{length(histogram) - 1 - index}: #{(prob.numerator / prob.denominator) * 100} %"
        #"#{length(histogram) - 1 - index}: #{prob.numerator}/#{prob.denominator}"
      end
    )
  end

  def print_histogram(nil) do
    "-"
  end
  def print_histogram(histogram) do
    Enum.map(
      histogram,
      fn bucket ->
        #"#{bucket.value}: #{(bucket.probability.numerator / bucket.probability.denominator) * 100} %"
        "#{bucket.value}: #{bucket.probability.numerator}/#{bucket.probability.denominator}"
      end
    )
  end

  @tag :integration
  describe "Integration" do

    test "case 1" do
      number_of_dice = 2

      attack = %Attack{
        number_of_dice: number_of_dice,
        skill: 4,
        strenght: 3,
        armor_penetration: 0,
        hit_modifiers: %HitModifiers{
          reroll: :reroll_none,
          on_six: :on_six_none,
        },
        wound_modifiers: %WoundModifiers{
          reroll: :reroll_ones,
          on_six: :on_six_none,
        },
      }
      defense = %Defense{
        resistance: 3
      }

      simulation =
        App.create_simulation(attack, defense)
        |> HitRoll.simulate()
        |> Reroll.simulate()
        |> WoundRoll.simulate()
        |> Reroll.simulate()

      sum =
        Enum.reduce(
          simulation.result.histogram,
          Fraction.new(0),
          fn bucket, acc ->
            Fraction.add(acc, bucket.probability)
          end
        )
      #IO.puts("\n\n::>> #{inspect(sum)}")
      foo = Fraction.add(
        Fraction.new(1, 16),
        Fraction.new(25, 1152)
      )
      IO.puts(":_:_:_:_: #{inspect(foo)}")

      IO.puts("\n\nHit phase:")
      IO.inspect(print_histogram(simulation.meta.hit_phase_histogram))
      IO.puts("\n\nHit phase after reroll:")
      IO.inspect(print_histogram(Map.get(simulation.meta, :hit_reroll_phase_histogram)))
      IO.puts("\n\nWound phase:")
      IO.inspect(print_histogram(Map.get(simulation.meta, :wound_phase_histogram)))
      IO.puts("\n\nWound phase after reroll:")
      IO.inspect(print_histogram(Map.get(simulation.meta, :wound_reroll_phase_histogram)))
    end

  end

end
