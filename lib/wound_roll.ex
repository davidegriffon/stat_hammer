defmodule WoundRoll do
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
