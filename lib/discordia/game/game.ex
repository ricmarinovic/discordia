defmodule Discordia.Game do
  def start_game(name, players) do
    Supervisor.start_child(Discordia.GameSupervisor, [name, players])
  end
end
