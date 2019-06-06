defmodule DiscordiaWeb.SessionController do
  use DiscordiaWeb, :controller

  @spec new(conn, params) :: conn
  def new(conn, _params) do
    if get_session(conn, :current_player) do
      redirect(conn, to: Routes.game_path(conn, :new))
    else
      render(conn, "new.html")
    end
  end

  @spec create(conn, params) :: conn
  def create(conn, %{"player" => %{"name" => name}}) do
    player = Discordia.Player.new(name)

    conn
    |> put_session(:current_player, player)
    |> redirect(to: Routes.game_path(conn, :new))
  end

  @spec delete(conn, params) :: conn
  def delete(conn, _params) do
    conn
    |> delete_session(:current_player)
    |> redirect(to: Routes.session_path(conn, :new))
  end
end
