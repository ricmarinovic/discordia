defmodule Discordia.Game do
  @enforce_keys [:name, :players, :status, :deck, :history]
  defstruct [:name, :players, :status, :deck, :history]

  @type game :: %__MODULE__{}
  @type card :: map

  @doc """
  Returns a new game struct.

  ## Possible status

    * `{:ok, :normal}`
    * `{:winner, player_name}`
  """
  @spec new(String.t(), [String.t()]) :: game
  def new(name, players) do
    [card | deck] = new_deck()

    %__MODULE__{
      name: name,
      players: players,
      status: {:ok, :normal},
      deck: deck,
      history: [%{card: set_black_colour(card), player: nil}]
    }
  end

  @doc """
  Removes the card from the top of the deck and returns it.
  """
  @spec draw_card(game) :: {card, game}
  def draw_card(%__MODULE__{deck: []} = game) do
    draw_card(%{game | deck: new_deck()})
  end

  def draw_card(%__MODULE__{deck: [card | rest]} = game) do
    {card, %{game | deck: rest}}
  end

  @doc """
  Plays the card.
  """
  @spec play_card(atom | game, String.t(), map) :: {:ok, game} | {:error, String.t()}
  def play_card(game, player, card) do
    %{colour: table_colour, value: table_value} = table_card(game)
    current_player = current_player(game)

    case {player, card} do
      {^current_player, %{colour: "black"}} ->
        commit_turn(game, player, set_black_colour(card))

      {^current_player, %{value: ^table_value}} ->
        commit_turn(game, player, card)

      {^current_player, %{colour: ^table_colour}} ->
        commit_turn(game, player, card)

      {_, %{colour: ^table_colour, value: ^table_value}} ->
        commit_turn(game, player, card)

      {^current_player, _} ->
        {:error, "Card does not match."}

      _ ->
        {:error, "Not player's turn."}
    end
  end

  @doc """
  Returns the card active on the table.
  """
  @spec table_card(game) :: map
  def table_card(game) do
    [%{card: table_card} | _] = game.history
    table_card
  end

  @doc """
  Returns the name of the player that can play this turn.
  """
  @spec current_player(game) :: String.t()
  def current_player(game) do
    [current_player | _] = game.players
    current_player
  end

  defp commit_turn(game, player, card) do
    turn = %{card: card, player: player}

    game =
      case card do
        %{value: "reverse"} ->
          reverse_players(game)

        %{value: "block"} ->
          block_next_player(game)

        %{value: "+" <> quantity} ->
          quantity = String.to_integer(quantity)

          Enum.reduce(1..quantity, game, fn _, game ->
            {card, game} = draw_card(game)
            Discordia.PlayerServer.add_card(game.name, player, card)
            game
          end)

          block_next_player(game)

        _ ->
          rotate_players(game)
      end

    {:ok, %{game | history: [turn | game.history]}}
  end

  def rotate_players(game) do
    [current_player | rest] = game.players
    %{game | players: rest ++ [current_player]}
  end

  defp reverse_players(game) do
    %{game | players: Enum.reverse(game.players)}
  end

  defp block_next_player(game) do
    game
    |> rotate_players()
    |> rotate_players()
  end

  defp set_black_colour(card) do
    with %{colour: "black"} <- card do
      %{card | colour: "blue"}
    end
  end

  @colours ["red", "green", "blue", "yellow"]

  defp new_deck do
    values = Enum.map(1..9, &Integer.to_string/1) ++ ["+2", "reverse", "block"]

    coloured =
      for value <- values, colour <- @colours do
        %{value: value, colour: colour}
      end

    zeros =
      for colour <- @colours do
        %{value: "0", colour: colour}
      end

    blacks =
      for value <- ["+4", "wildcard"], _colour <- @colours do
        %{value: value, colour: "black"}
      end

    deck = coloured ++ coloured ++ zeros ++ blacks

    Enum.shuffle(deck)
  end
end
