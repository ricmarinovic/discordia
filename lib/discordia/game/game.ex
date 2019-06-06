defmodule Discordia.Game do
  defstruct [:deck, :history]

  def new do
    [card | deck] = Discordia.Dealer.new_deck()
    initial_turn = %{turn: 0, card: card, player: nil}

    %{deck: deck, history: [initial_turn]}
  end
end
