defmodule Discordia.Web.GameChannel do
  use Phoenix.Channel

  alias Discordia.Web.Presence

  def join("room:" <> room_name, _, socket) do
    send self(), :after_join
    {:ok, assign(socket, :room, room_name)}
  end

  def handle_info(:after_join, socket) do
    Presence.track(socket, socket.assigns.username, %{
      online_at: :os.system_time(:milli_seconds)
    })
    push socket, "presence_state", Presence.list(socket)
    {:noreply, socket}
  end
end
