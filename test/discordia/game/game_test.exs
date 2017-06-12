defmodule Discordia.GameTest do
  use ExUnit.Case

  alias Discordia.{Game, GameServer, Player, RoomSupervisor}

  @initial_cards 7

  setup do
    name = "game name"
    players = [p1, p2] = ["eu", "voce"]
    Game.start(name, players)

    on_exit fn() -> RoomSupervisor.stop(name) end

    game = %{
      name: name,
      players: players,
      p1: p1,
      p2: p2,
      cards: [
        %{color: "red", value: "3"},
        %{color: "green", value: "6"},
        %{color: "yellow", value: "4"},
        %{color: "red", value: "1"},
        %{color: "blue", value: "2"},
        %{color: "red", value: "3"},
      ]
    }

    {:ok, game}
  end

  test "first turn", game do
    assert GameServer.current_player(game.name) == game.p1
    assert length(Player.cards(game.name, game.p1)) == @initial_cards
    assert length(Player.cards(game.name, game.p2)) == @initial_cards
  end

  test "drawing cards", game do
    {:ok, _card} = Game.draw(game.name, game.p1)
    assert length(Player.cards(game.name, game.p1)) == @initial_cards + 1
    {:error, _} = Game.draw(game.name, game.p2)
    assert length(Player.cards(game.name, game.p2)) == @initial_cards
  end

  test "cracking up a new deck", game do
    Player.draws(game.name, game.p1, 93)
    assert length(Player.cards(game.name, game.p1)) == @initial_cards + 93
    assert length(GameServer.deck(game.name)) == 0

    Player.draws(game.name, game.p1)
    assert length(GameServer.deck(game.name)) == 107
  end

  test "playing a black card", game do
    card = %{color: "black", value: "wildcard"}
    assert {:error, _} = Game.play(game.name, game.p1, card)
    cards = Player.cards(game.name, game.p1) ++ [card]
    Player.set_cards(game.name, game.p1, cards)
    :ok = Game.play(game.name, game.p1, card, next = "red")
    assert GameServer.current_card(game.name) == Map.put(card, :next, "red")
    assert GameServer.current_card(game.name).next == next
    refute card in Player.cards(game.name, game.p1)
    assert GameServer.current_player(game.name) == game.p2
  end

  test "playing on top of a black card", game do
    GameServer.put_card(game.name, %{color: "black", value: "+4"}, "red")
    card = %{color: "red", value: "3"}
    Player.set_cards(game.name, game.p1, game.cards ++ [card])
    :ok = Game.play(game.name, game.p1, card, "red")
    assert GameServer.current_card(game.name) == card
  end

  test "playing reverse and block cards", game do
    game_name = "other game"
    players = [p1, p2, p3, p4] =
      ["p1", "p2", "p3", "p4"]
    Game.start(game_name, players)

    GameServer.put_card(game_name, %{color: "blue", value: "7"})

    card = %{color: "blue", value: "1"}
    Player.set_cards(game_name, p1, game.cards ++ [card])
    :ok = Game.play(game_name, p1, card)
    assert GameServer.current_player(game_name) == p2

    card = %{color: "blue", value: "2"}
    Player.set_cards(game_name, p2, game.cards ++ [card])
    :ok = Game.play(game_name, p2, card)
    assert GameServer.current_player(game_name) == p3

    card = %{color: "blue", value: "reverse"}
    Player.set_cards(game_name, p3, game.cards ++ [card])
    :ok = Game.play(game_name, p3, card)
    assert GameServer.current_player(game_name) == p2

    card = %{color: "blue", value: "block"}
    Player.set_cards(game_name, p2, game.cards ++ [card])
    :ok = Game.play(game_name, p2, card)
    assert GameServer.current_player(game_name) == p4

    card = %{color: "blue", value: "reverse"}
    Player.set_cards(game_name, p4, game.cards ++ [card])
    :ok = Game.play(game_name, p4, card)
    assert GameServer.current_player(game_name) == p1
    assert GameServer.player_queue(game_name) == players
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

    card = %{color: "black", value: "+4"}

    Player.set_cards(game.name, game.p1, cards ++ [card])
    Player.set_cards(game.name, game.p2,
        cards ++ [%{color: "blus", value: "1"}])

    :ok = Game.play(game.name, game.p1, card, "red")
    assert GameServer.current_card(game.name) == Map.put(card, :next, "red")
    assert length(Player.cards(game.name, game.p2)) == @initial_cards + 4
    assert GameServer.current_player(game.name) == game.p1
    :ok = Game.play(game.name, game.p1, %{color: "red", value: "3"})
    assert GameServer.current_player(game.name) == game.p2

    Player.set_cards(game.name, game.p1, cards ++ [card])
    Player.set_cards(game.name, game.p2, cards ++ [card])
    :ok = Game.play(game.name, game.p2, card, "red")
    assert length(Player.cards(game.name, game.p1)) == @initial_cards
    assert GameServer.current_player(game.name) == game.p1
    {:error, "Player must play a +4 card."} = Game.play(game.name, game.p1, %{color: "red", value: "3"})
    assert GameServer.current_player(game.name) == game.p1
    :ok = Game.play(game.name, game.p1, card, "red")
    assert GameServer.current_player(game.name) == game.p1
  end

  test "block with two players", game do
    GameServer.put_card(game.name, %{color: "blue", value: "7"})

    card = %{color: "blue", value: "3"}
    Player.set_cards(game.name, game.p1, game.cards ++ [card])
    :ok = Game.play(game.name, game.p1, card)
    assert GameServer.current_player(game.name) == game.p2

    card = %{color: "blue", value: "4"}
    Player.set_cards(game.name, game.p2, game.cards ++ [card])
    :ok = Game.play(game.name, game.p2, card)
    assert GameServer.current_player(game.name) == game.p1

    card = %{color: "blue", value: "block"}
    Player.set_cards(game.name, game.p1, game.cards ++ [card])
    :ok = Game.play(game.name, game.p1, card)
    assert GameServer.current_player(game.name) == game.p1

    card = %{color: "blue", value: "reverse"}
    Player.set_cards(game.name, game.p1, game.cards ++ [card])
    :ok = Game.play(game.name, game.p1, card)
    assert GameServer.current_player(game.name) == game.p2
  end

  test "ending a game"
end
