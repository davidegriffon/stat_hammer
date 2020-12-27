defmodule StatHammer.Phases.WoundRoll do
  alias StatHammer.Math.Fraction
  alias StatHammer.Structs.Simulation

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

  @spec calculate(Simulation.t()) :: Simulation.t()
  def calculate(simulation = %Simulation{}) do
    simulation
  end
end
