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
  def play(_game, _player, %{color: "black"}) do
    {:error, "Must provide the next card color."}
  end
  def play(game, player, card, next \\ nil) do
    with  {:ok, _status} <- check_status(game, card),
          {:ok, _card} <- has_card(game, player, card),
          {:ok, _card} <- playable(game, card),
          {:ok, _player} <- allowed_to_play(game, player)
    do
      remove_card(game, player, card) # Remove card from player's hand

      case card do
        %{color: "black"} ->
          make_play(game, player, card, next)
        _ ->
          make_play(game, player, card)
      end

      turn(game) # This turn is over, next turn
      # TODO: If player has no more cards, the game is over.
      :ok
    end
  end

  @doc """
  The `player` draws a card from the deck. It is still his turn.
  """
  def draw(game, player) do
    # TODO: Player can only draw 5 cards.
    # TODO: Only the current player can draw.
    [card] = draws(game, player)
    info(game, Mix.env) # TODO: Remove info
    {:ok, card}
  end

  @doc false
  def check_status(game, card) do
    status = status(game) # {:plus_hold, +2}
    value = card.value

    case status do
      {:plus_hold, ^value} ->
        status(game, {:started, :normal})
        {:ok, status}
      {:plus_hold, status_value} ->
        {:error, "Player must play a #{status_value} card."}
      {:ended, _} ->
        {:error, "Game is over."}
      {_, _} ->
        {:ok, status}
    end
  end

  @doc false
  def playable(game, card) do
    current = current_card(game)
    %{color: color, value: value} = current
    next = Map.get(current, :next)

    case card do
      %{color: "black"} ->
        {:ok, card}
      %{value: ^value} ->
        {:ok, card}
      %{color: ^color} ->
        {:ok, card}
      %{color: ^next} ->
        {:ok, card}
      _ ->
        {:error, "Card does not match."}
    end
  end

  # TODO: Check if player is current player. Will be dropped when cutting
  #       is allowed
  @doc false
  def allowed_to_play(game, player) do
    current = current_player(game)

    if player === current do
      {:ok, player}
    else
      {:error, "Not this player's turn."}
    end
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
