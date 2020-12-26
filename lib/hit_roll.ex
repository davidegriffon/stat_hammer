defmodule HitRoll do
  import Fraction

  def to_hit(ballistic_skill) when not is_integer(ballistic_skill) do
    raise ArgumentError, message: "Ballistic skill must be an integer"
  end
  def to_hit(ballistic_skill) when ballistic_skill < 2 or ballistic_skill > 6 do
    raise ArgumentError, message: "Ballistic skill must be in range 2...6"
  end
  def to_hit(ballistic_skill) do
    Fraction.new(7 - ballistic_skill, 6)
  end

  def to_hit(ballistic_skill, _number_of_dice) when ballistic_skill < 2 or ballistic_skill > 6 do
    raise ArgumentError, message: "Ballistic skill must be in range 2...6"
  end
  def to_hit(_ballistic_skill, number_of_dice) when number_of_dice < 1 or number_of_dice > 50 do
    raise ArgumentError, message: "Number of dice must be in range 1..50"
  end

  def to_hit(ballistic_skill, number_of_dice) do
    Enum.map(
      0..number_of_dice,
      fn x -> {x, probabilty_to_hit_n_times(ballistic_skill, number_of_dice, x)} end
    )
  end

  def to_miss(ballistic_skill) do
    subtraction(Fraction.new(1), to_hit(ballistic_skill))
  end

  def probabilty_to_hit_n_times(_ballistic_skill, number_of_dice, number_of_hits) when number_of_dice < number_of_hits do
    raise ArgumentError, message: "number_of_dice >= number_of_hits"
  end

  def probabilty_to_hit_n_times(ballistic_skill, number_of_dice, number_of_hits) when number_of_dice == number_of_hits do
    pow(to_hit(ballistic_skill), number_of_dice)
  end

  def probabilty_to_hit_n_times(ballistic_skill, number_of_dice, 0) do
    pow(to_miss(ballistic_skill), number_of_dice)
  end

  def probabilty_to_hit_n_times(ballistic_skill, number_of_dice, number_of_hits) do
    hit = pow(to_hit(ballistic_skill), number_of_hits)
    miss = pow(to_miss(ballistic_skill), number_of_dice - number_of_hits)
    possible_world = multiply(hit, miss)

    multiply(
      possible_world,
      Combinations.of(number_of_dice, number_of_hits)
    )
  end

  def to_wound(strenght, resistance) when (strenght / 2) >= resistance do
    Fraction.new(5, 6)
  end
  def to_wound(strenght, resistance) when strenght > resistance do
    Fraction.new(4, 6)
  end
  def to_wound(strenght, resistance) when strenght == resistance do
    Fraction.new(3, 6)
  end
  def to_wound(strenght, resistance) when (strenght / 2) <= resistance do
    Fraction.new(1, 6)
  end
  def to_wound(strenght, resistance) when strenght < resistance do
    Fraction.new(2, 6)
  end
end
