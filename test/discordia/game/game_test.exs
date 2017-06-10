defmodule Discordia.GameTest do
  use ExUnit.Case

  alias Discordia.{Game, GameServer, GameSupervisor, Player}

  setup_all do
    name = "game name"
    players = [p1, p2] = ["eu", "voce"]
    Game.start(name, players)

    {:ok, %{name: name, players: players, p1: p1, p2: p2}}
  end

  test "starting a new game", game do
    assert %{supervisors: 1} = Supervisor.count_children(GameSupervisor)

    via_sup = {:global, "sup@#{game.name}"}
    assert %{active: 3} = Supervisor.count_children(via_sup)
  end

  test "first turn", game do
    initial_cards = 7

    assert GameServer.current_player(game.name) == game.p1
    assert length(Player.cards(game.name, game.p1)) == initial_cards
    assert length(Player.cards(game.name, game.p2)) == initial_cards
  end
end
