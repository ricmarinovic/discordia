defmodule Discordia.GameServer do
  use GenServer

  def start_link(name, players) do
    {:ok, _pid} = GenServer.start_link(__MODULE__,
      %{
        players: players,
      }, name: via(name))
  end

  def via(name), do: {:global, name}

  def players(game), do: GenServer.call(via(game), :get_players)

  # Callbacks

  def handle_call(:get_players, _from, state = %{players: players}) do
    {:reply, players, state}
  end
end
