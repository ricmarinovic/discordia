defmodule DiscordiaWeb.GameController do
  use DiscordiaWeb, :controller

  plug :require_player

  @spec show(conn, params) :: conn
  def show(conn, %{"id" => game_name}) do
    current_player = get_session(conn, :current_player)
    session = %{game_name: game_name, current_player: current_player}

    conn
    |> live_render(DiscordiaWeb.GameLive, session: session)
  end

  defp require_player(conn, _opts) do
    if get_session(conn, :current_player) do
      conn
    else
      conn
      |> put_session(:return_to, conn.request_path)
      |> redirect(to: Routes.session_path(conn, :new))
      |> halt()
    end
  end
end
