defmodule Discordia.Game do
  @moduledoc """
  Controls the flow of the game.
  """

  import Discordia.GameServer, except: [start_link: 2, via: 1]
  import Discordia.PlayerServer, except: [start_link: 2, via: 2]

  @initial_cards 7

  @doc """
  Starts a game, provided a name for the game and a list of players.
  """
  def start(name, players) do
    Supervisor.start_child(Discordia.GameSupervisor, [name, players])
    turn(name, current_turn(name))
  end

  @doc """
  The `player` plays a `card` and another turn is started.
  """
  def play(game, player, card) do
    # Put card on the table
    current_card(game, card)

    # Remove card from player's hand
    remove_card(game, player, card)

    # This turn is over, next turn
    turn(game, inc_turn(game))
  end

  defp turn(game, 0) do
    # Set the first player to play
    [player | _] = players(game)
    current_player(game, player)

    # Draw and put the first card on the table
    card = draw_card(game)
    current_card(game, card)

    # Each player gets 7 cards
    for player <- players(game) do
      player_draws(game, player, @initial_cards)
    end
  end
  defp turn(_game, _turn), do: nil
end
