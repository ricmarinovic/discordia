defmodule Discordia.GameTest do
  use ExUnit.Case

  alias Discordia.{Game, GameServer, GameSupervisor, PlayerServer}

  setup_all do
    game_name = "game name"
    players = ["eu", "voce"]
    Game.start(game_name, players)

    {:ok, %{name: game_name, players: players}}
  end

  test "starting a new game", game do
    assert %{supervisors: 1} = Supervisor.count_children(GameSupervisor)

    via_sup = {:global, "sup@#{game.name}"}
    assert %{active: 3} = Supervisor.count_children(via_sup)
  end

  test "first turn", game do
    [p1, p2] = game.players
    initial_cards = 7

    assert GameServer.current_player(game.name) == p1
    assert length(PlayerServer.cards(game.name, p1)) == initial_cards
    assert length(PlayerServer.cards(game.name, p2)) == initial_cards
  end

  test "playing a card", game do
    [p1, _p2] = game.players
    Game.play(game.name, p1, %{})

    assert GameServer.current_turn(game.name) == 1
  end
end
