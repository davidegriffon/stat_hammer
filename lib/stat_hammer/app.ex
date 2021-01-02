defmodule StatHammer.App do
  alias StatHammer.Structs.Attack
  alias StatHammer.Structs.Defense
  alias StatHammer.Structs.Simulation
  alias StatHammer.Structs.SimulationResult
  alias StatHammer.Phases.HitRoll
  alias StatHammer.Phases.Reroll
  alias StatHammer.Phases.WoundRoll
  alias StatHammer.Phases.SavingRoll

  @spec simulate(Attack.t(), Defense.t()) :: Simulation.t()
  def simulate(attack = %Attack{}, defense = %Defense{}) do
    create_simulation(attack, defense)
    |> hit_roll()
    |> reroll(:hit_phase)
    |> apply_six_results(:hit_phase)
    |> wound_roll()
    |> reroll(:wound_phase)
    |> apply_six_results(:wound_phase)
    |> saving_throw()
    |> inflict_damage()
  end

  def hit_roll(simulation = %Simulation{}) do
    simulation
    |> HitRoll.apply()
  end

  def reroll(simulation = %Simulation{}, :hit_phase) do
    simulation
    |> Reroll.apply()
  end
  def reroll(simulation = %Simulation{}, :wound_phase) do
    simulation
  end

  def apply_six_results(simulation = %Simulation{}, :hit_phase) do
    simulation
  end
  def apply_six_results(simulation = %Simulation{}, :wound_phase) do
    simulation
  end

  def wound_roll(simulation = %Simulation{}) do
    simulation
  end

  def saving_throw(simulation = %Simulation{}) do
    simulation
  end

  def inflict_damage(simulation = %Simulation{}) do
    simulation
  end

  def create_simulation(attack = %Attack{}, defense = %Defense{}) do
    %Simulation{
      attack: attack,
      defense: defense,
      result: %SimulationResult{},
      meta: %{},
    }
  end
end
