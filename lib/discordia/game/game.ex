defmodule Discordia.Game do
  @moduledoc """
  Controls the flow of the game.
  """

  @doc """
  Starts a game, provided a name for the game and a list of players.
  """
  def start(name, players) do
    Supervisor.start_child(Discordia.GameSupervisor, [name, players])
  end
end
