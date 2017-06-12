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

  defp set_card_and_play(game, player, card) do
    Player.set_cards(game, player, [card])
    :ok = Game.play(game, player, card)
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
    Player.draws(game.name, game.p1, 93)
    assert length(Player.cards(game.name, game.p1)) == @initial_cards + 93
    assert length(GameServer.deck(game.name)) == 0

    Player.draws(game.name, game.p1)
    assert length(GameServer.deck(game.name)) == 107
  end

  test "playing a black card", game do
    card = %{color: "black", value: "wildcard", next: nil}
    assert {:error, _} = Game.play(game.name, game.p1, card)
    cards = Player.cards(game.name, game.p1) ++ [card]
    Player.set_cards(game.name, game.p1, cards)
    :ok = Game.play(game.name, game.p1, %{card | next: "red"})
    assert GameServer.current_card(game.name) == card
    assert GameServer.current_card(game.name).next == "red"
    refute card in Player.cards(game.name, game.p1)
    assert GameServer.current_player(game.name) == game.p2
  end

  test "playing reverse and block cards" do
    other_game = "other game"
    players = [p1, p2, p3, p4] =
      ["p1", "p2", "p3", "p4"]
    Game.start(other_game, players)

    GameServer.put_card(other_game, %{color: "blue", value: "7"})

    card = %{color: "blue", value: "1"}
    set_card_and_play(other_game, p1, card)
    assert GameServer.current_player(other_game) == p2

    card = %{color: "blue", value: "2"}
    set_card_and_play(other_game, p2, card)
    assert GameServer.current_player(other_game) == p3

    card = %{color: "blue", value: "reverse"}
    set_card_and_play(other_game, p3, card)
    assert GameServer.current_player(other_game) == p2

    card = %{color: "blue", value: "block"}
    set_card_and_play(other_game, p2, card)
    assert GameServer.current_player(other_game) == p4

    card = %{color: "blue", value: "reverse"}
    set_card_and_play(other_game, p4, card)
    assert GameServer.current_player(other_game) == p1
    assert GameServer.player_queue(other_game) == players
  end

  test "playing +2 and +4 cards", game do
    assert GameServer.whois_next(game.name) == game.p2
    assert length(Player.cards(game.name, game.p1)) == @initial_cards
    assert length(Player.cards(game.name, game.p2)) == @initial_cards

    cards = [
      %{color: "red", value: "3"},
      %{color: "red", value: "6"},
      %{color: "yellow", value: "4"},
      %{color: "red", value: "1"},
      %{color: "red", value: "2"},
      %{color: "red", value: "3"},
    ]

    card = %{color: "black", value: "+4", next: "red"}

    Player.set_cards(game.name, game.p1, cards ++ [card])
    Player.set_cards(game.name, game.p2,
        cards ++ [%{color: "blus", value: "1"}])

    :ok = Game.play(game.name, game.p1, card)
    assert GameServer.current_card(game.name) == card
    assert length(Player.cards(game.name, game.p2)) == @initial_cards + 4
    assert GameServer.current_player(game.name) == game.p1
    :ok = Game.play(game.name, game.p1, %{color: "red", value: "3"})
    assert GameServer.current_player(game.name) == game.p2

    Player.set_cards(game.name, game.p1, cards ++ [card])
    Player.set_cards(game.name, game.p2, cards ++ [card])
    :ok = Game.play(game.name, game.p2, card)
    assert length(Player.cards(game.name, game.p1)) == @initial_cards
    assert GameServer.current_player(game.name) == game.p1
    {:error, "Player must play a +4 card."} = Game.play(game.name, game.p1, %{color: "red", value: "3"})
    assert GameServer.current_player(game.name) == game.p1
    :ok = Game.play(game.name, game.p1, card)
    assert GameServer.current_player(game.name) == game.p1
  end

  test "block with two players", game do
    GameServer.put_card(game.name, %{color: "blue", value: "7"})

    card = %{color: "blue", value: "3"}
    set_card_and_play(game.name, game.p1, card)
    assert GameServer.current_player(game.name) == game.p2

    card = %{color: "blue", value: "4"}
    set_card_and_play(game.name, game.p2, card)
    assert GameServer.current_player(game.name) == game.p1

    card = %{color: "blue", value: "block"}
    set_card_and_play(game.name, game.p1, card)
    assert GameServer.current_player(game.name) == game.p1

    card = %{color: "blue", value: "reverse"}
    set_card_and_play(game.name, game.p1, card)
    assert GameServer.current_player(game.name) == game.p2
  end

  test "playing on top of a black card", game do
    GameServer.put_card(game.name, %{color: "black", value: "+4", next: "red"})
    card = %{color: "red", value: "3"}
    set_card_and_play(game.name, game.p1, card)
    assert GameServer.current_card(game.name) == card
  end
end
