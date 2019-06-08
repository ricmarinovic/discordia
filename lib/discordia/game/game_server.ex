defmodule Discordia.GameServer do
  use GenServer

  @timeout :timer.minutes(30)

  def start_link(game_name) do
    GenServer.start_link(__MODULE__, {game_name}, name: via_tuple(game_name))
  end

  defp via_tuple(game_name), do: {:via, Registry, {Discordia.GameRegistry, game_name}}

  @impl GenServer
  def init({_game_name}) do
    game = Discordia.Game.new()
    {:ok, game, @timeout}
  end

  def game_pid(game_name) do
    game_name
    |> via_tuple()
    |> GenServer.whereis()
  end
end
