defmodule Discordia.RoomSupervisor do
  @moduledoc """
  Supervises a individual game and its players.
  """

  use Supervisor

  alias Discordia.{GameServer, Player}

  def start_link(game, players) do
    via = {:global, "sup@#{game}"}
    {:ok, _} = Supervisor.start_link(__MODULE__, [game, players], name: via)
  end

  def init([game, players]) do
    children = [
      worker(GameServer, [game, players])
    ] ++ for player <- players do
      worker(Player, [game, player], id: "@#{game}:#{player}")
    end

    supervise(children, strategy: :one_for_one)
  end
end
