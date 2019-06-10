defmodule Discordia.GameServer do
  use GenServer

  @timeout :timer.minutes(30)

  def start_link(game_name, players) do
    GenServer.start_link(__MODULE__, {game_name, players}, name: via_tuple(game_name))
  end

  defp via_tuple(game_name), do: {:via, Registry, {Discordia.GameRegistry, game_name}}

  def game_pid(game_name) do
    game_name
    |> via_tuple()
    |> GenServer.whereis()
  end

  def summary(game_name) do
    GenServer.call(via_tuple(game_name), :summary)
  end

  @impl GenServer
  def init({_game_name, players}) do
    {:ok, Discordia.Game.new(players), @timeout}
  end

  @impl GenServer
  def handle_call(:summary, _from, game) do
    {:reply, game, game, @timeout}
  end
end
