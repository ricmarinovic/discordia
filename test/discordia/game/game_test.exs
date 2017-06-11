defmodule Discordia.GameTest do
  use ExUnit.Case

  alias Discordia.{Game, GameServer, Player, RoomSupervisor}

  @initial_cards 7

  setup do
    name = "game name"
    players = [p1, p2] = ["eu", "voce"]
    Game.start(name, players)

    on_exit fn() -> RoomSupervisor.stop(name) end

    {:ok, %{name: name, players: players, p1: p1, p2: p2}}
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
    GameServer.put_card(game.name, card, "red")
    assert GameServer.current_card(game.name) == %{card | next: "red"}
  end

  test "playing a black card", game do
    card = %{color: "black", value: "wildcard", next: nil}
    assert {:error, _} = Game.play(game.name, game.p1, card)

    card = %{color: "black", value: "wildcard", next: "red"}
    Game.play(game.name, game.p1, card)
    assert GameServer.current_card(game.name) == card
    refute card in Player.cards(game.name, game.p1)
    assert GameServer.current_player(game.name) == game.p2
  end

  test "playing reverse card" do
    other_game = "other game"
    players = [p1, p2, p3, p4] =
      ["p1", "p2", "p3", "p4"]
    Game.start(other_game, players)

    Game.play(other_game, p1, %{color: "blue", value: "1"})
    assert GameServer.current_player(other_game) == p2
    Game.play(other_game, p2, %{color: "blue", value: "2"})
    assert GameServer.current_player(other_game) == p3
    Game.play(other_game, p3, %{color: "blue", value: "reverse"})
    assert GameServer.current_player(other_game) == p2
    Game.play(other_game, p2, %{color: "blue", value: "block"})
    assert GameServer.current_player(other_game) == p4
    Game.play(other_game, p4, %{color: "blue", value: "reverse"})
    assert GameServer.current_player(other_game) == p1
    assert GameServer.player_queue(other_game) == players
  end
end
