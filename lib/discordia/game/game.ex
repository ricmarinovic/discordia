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
    turn(name, current_turn(name))
  end

  @doc """
  The `player` plays a `card` and another turn is started.
  """
  def play(game, player, card) do
    # Put card on the table
    play_card(game, card)

    # Remove card from player's hand
    remove_card(game, player, card)

    # This turn is over, next turn
    turn(game, inc_turn(game))
  end

  @doc """
  The `player` draws a card from the deck. It is still his turn.
  """
  def draw(game, player) do
    [card] = player_draws(game, player)
    info(game, Mix.env)
    card
  end

  defp turn(game, _turn = 0) do
    # Draw and put the first card on the table
    play_card(game, draw_card(game))

    # Each player gets 7 cards
    for player <- players(game) do
      player_draws(game, player, @initial_cards)
    end

    info(game, Mix.env)
  end
  defp turn(game, _turn) do
    next_player(game)

    info(game, Mix.env)
  end

  def info(game, env) when env == :dev do
    IO.puts "\nTurn #{current_turn(game)}"
    current_card = current_card(game)
    IO.puts "Current card: #{current_card.value} #{current_card.color}"
    current_player = current_player(game)
    IO.puts "Current player *#{current_player}* cards:"
    IO.inspect(cards(game, current_player))

    :ok
  end
  def info(_game, _env), do: nil
end
