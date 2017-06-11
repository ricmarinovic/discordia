defmodule Discordia.GameTest do
  use ExUnit.Case

  alias Discordia.{Game, GameServer, GameSupervisor, Player, RoomSupervisor}

  @initial_cards 7

  setup do
    name = "game name"
    players = [p1, p2] = ["eu", "voce"]
    Game.start(name, players)

    on_exit fn() -> RoomSupervisor.stop(name) end

    {:ok, %{name: name, players: players, p1: p1, p2: p2}}
  end

  test "starting a new game", game do
    assert %{supervisors: 1} = Supervisor.count_children(GameSupervisor)

    via_sup = RoomSupervisor.via(game.name)
    assert %{active: 3} = Supervisor.count_children(via_sup)
  end

  test "first turn", game do
    @initial_cards = 7
    assert GameServer.current_player(game.name) == game.p1
    assert length(Player.cards(game.name, game.p1)) == @initial_cards
    assert length(Player.cards(game.name, game.p2)) == @initial_cards
  end

  test "drawing cards", game do
    Game.draw(game.name, game.p1)
    assert length(Player.cards(game.name, game.p1)) == @initial_cards + 1
  end

  test "cracking up a new deck", game do
    Player.player_draws(game.name, game.p1, 93)
    assert length(Player.cards(game.name, game.p1)) == @initial_cards + 93
    assert length(GameServer.deck(game.name)) == 0

    Player.player_draws(game.name, game.p1)
    assert length(GameServer.deck(game.name)) == 107
  end

  test "initial black card", game do
    card = %{color: "black", value: "wildcard", next: nil}
    GameServer.play_card(game.name, card, "red")
    assert GameServer.current_card(game.name) == %{card | next: "red"}
  end
end
