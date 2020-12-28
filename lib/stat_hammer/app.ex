defmodule StatHammer.App do
  alias StatHammer.Structs.Attack
  alias StatHammer.Structs.Defense
  alias StatHammer.Structs.Simulation
  alias StatHammer.Phases.HitRoll
  alias StatHammer.Phases.WoundRoll
  alias StatHammer.Phases.SavingRoll

  @spec calculate(Attack.t(), Defense.t()) :: Simulation.t()
  def calculate(attack = %Attack{}, defense = %Defense{}) do
    create_simulation(attack, defense)
    |> HitRoll.apply()
    |> Reroll.apply()
    |> WoundRoll.calculate()
    |> SavingRoll.calculate()
  end

  defp create_simulation(attack = %Attack{}, defense = %Defense{}) do
    %Simulation{
      attack: attack,
      defense: defense,
      hit_histogram: nil,
      wound_result: nil,
      saving_result: nil,
    }
  end
end
