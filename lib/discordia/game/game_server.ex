defmodule Discordia.GameServer do
  @moduledoc """
  Holds the state of a single game.
  """

  use GenServer

  def start_link(game, players) do
    GenServer.start_link(__MODULE__,
      %{
        players: players,
      }, name: via(game))
  end

  def via(game), do: {:global, "@#{game}"}

  def players(game), do: GenServer.call(via(game), :get_players)

  # Callbacks

  def handle_call(:get_players, _from, state = %{players: players}) do
    {:reply, players, state}
  end
end
