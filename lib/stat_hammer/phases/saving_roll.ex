defmodule StatHammer.Phases.SavingRoll do
  alias StatHammer.Structs.Simulation

  @spec calculate(Simulation.t()) :: Simulation.t()
  def calculate(simulation = %Simulation{}) do
    simulation
  end
end
