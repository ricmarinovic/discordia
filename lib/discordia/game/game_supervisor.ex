defmodule Discordia.GameSupervisor do
  use DynamicSupervisor

  alias Discordia.GameServer

  require Logger

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl DynamicSupervisor
  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @doc """
  Starts a supervised `GameServer` process.

  """
  def start_game(game_name) do
    child_spec = %{
      id: GameServer,
      start: {GameServer, :start_link, [game_name]},
      restart: :transient
    }

    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  @spec stop_game(String.t()) :: nil | :ok
  def stop_game(game_name) do
    with pid when is_pid(pid) <- GameServer.game_pid(game_name) do
      Logger.info("Terminating game #{game_name}.")
      DynamicSupervisor.terminate_child(__MODULE__, pid)
    end
  end
end
