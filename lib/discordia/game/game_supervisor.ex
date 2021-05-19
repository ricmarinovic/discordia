defmodule Discordia.GameSupervisor do
  use DynamicSupervisor

  alias Discordia.GameServer

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_game(game_name, players) do
    child_spec = %{
      id: GameServer,
      start: {GameServer, :start_link, [game_name, players]},
      restart: :transient
    }

    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  def stop_game(game_name) do
    with pid when is_pid(pid) <- GameServer.game_pid(game_name) do
      DynamicSupervisor.terminate_child(__MODULE__, pid)
    end
  end
end
