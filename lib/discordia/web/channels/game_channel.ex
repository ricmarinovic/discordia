defmodule Discordia.Web.GameChannel do
  use Phoenix.Channel

  def join("room:" <> _game_name, _message, socket) do
    {:ok, socket}
  end
end
