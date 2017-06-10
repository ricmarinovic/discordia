defmodule Discordia.GameTest do
  use ExUnit.Case

  alias Discordia.{Game, GameSupervisor}

  test "creating a new game" do
    game = "game name"
    players = ["eu", "voce"]

    assert {:ok, _} = Game.start(game, players)
    assert %{supervisors: 1} = Supervisor.count_children(GameSupervisor)
    assert %{active: 3} = Supervisor.count_children({:global, "sup@#{game}"})
  end
end
