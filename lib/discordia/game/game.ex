defmodule Discordia.Game do
  @moduledoc """
  Controls the flow of the game.
  """

  import Discordia.GameServer, except: [start_link: 2, via: 1]
  import Discordia.Player, except: [start_link: 2, via: 2]

  @initial_cards 7

  @doc """
  Starts a game, provided a name for the game and a list of players.
  """
  def start(name, players) do
    {:ok, _} = Supervisor.start_child(Discordia.GameSupervisor, [name, players])
    turn(name, :first)
  end

  @doc """
  The `player` plays a `card` and another turn is started.
  """
  def play(game, player, card = %{color: "black", next: next}) when next != nil do
    play(game, player, card, next)
  end
  def play(_game, _player, %{color: "black"}) do
    {:error, "Must provide the next card color."}
  end
  def play(game, player, card, _next \\ nil) do
    # TODO: Check if game is over
    # TODO: Check if player must play a +2/+4 card. (status :plus_hold)
    # TODO: Check if card is on player's hand
    # TODO: Check if card is playable (same color or value)
    # TODO: Check if player is current player. Will be dropped when cutting
    #       is allowed

    remove_card(game, player, card) # Remove card from player's hand
    make_play(game, player, card) # Put card on the table

    turn(game) # This turn is over, next turn
    :ok
  end

  @doc """
  The `player` draws a card from the deck. It is still his turn.
  """
  def draw(game, player) do
    [card] = draws(game, player)
    info(game, Mix.env) # TODO: Remove info
    {:ok, card}
  end

  defp turn(game, :first) do
    # Draw and put the first card on the table
    put_card(game, draw_card(game))

    # Each player gets 7 cards
    for player <- players(game) do
      draws(game, player, @initial_cards)
    end

    info(game, Mix.env) # TODO: Remove info
  end
  defp turn(game) do
    info(game, Mix.env) # TODO: Remove info
  end

  def info(game, env) when env == :dev do # TODO: Remove info
    IO.puts "\nTurn #{current_turn(game)}"
    IO.puts "Current card: "
    IO.inspect current_card(game)
    current_player = current_player(game)
    IO.puts "Current player *#{current_player}* cards:"
    IO.inspect(cards(game, current_player))

    :ok
  end
  def info(_game, _env), do: nil
end
