defmodule Discordia.PlayerServer do
  use GenServer

  @timeout :timer.minutes(30)

  def start_link(player_name) do
    GenServer.start_link(__MODULE__, {player_name}, name: via_tuple(player_name))
  end

  defp via_tuple(player_name), do: {:via, Registry, {Discordia.PlayerRegistry, player_name}}

  def init({player_name}) do
    player = Discordia.Player.new(player_name)
    {:ok, player, @timeout}
  end

  def player_pid(player_name) do
    player_name
    |> via_tuple()
    |> GenServer.whereis()
  end
end
