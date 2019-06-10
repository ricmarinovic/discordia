defmodule Discordia.Game do
  defstruct [:deck, :history, :players]

  def new(players) do
    [card | deck] = Discordia.Dealer.new_deck()
    initial_turn = %{turn: 0, card: card, player: nil}

    %{players: players, deck: deck, history: [initial_turn]}
  end

  def generate_game_name do
    name_length = 4

    name_length
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64()
    |> binary_part(0, name_length)
  end
end
