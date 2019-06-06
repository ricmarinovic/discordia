defmodule DiscordiaWeb.GameController do
  use DiscordiaWeb, :controller

  plug :require_player

  @spec new(conn, params) :: conn
  def new(conn, _params) do
    game_name = generate_game_name()

    conn
    |> put_session(:game_name, game_name)
    |> assign(:game_name, game_name)
    |> assign(:auth_token, generate_auth_token(conn))
    |> render("new.html")
  end

  @spec create(conn, params) :: conn
  def create(conn, _params) do
    game_name = get_session(conn, :game_name)

    case Discordia.GameSupervisor.start_game(game_name) do
      {:ok, _game_pid} ->
        redirect(conn, to: Routes.game_path(conn, :show, game_name))

      {:error, _reason} ->
        conn
        |> put_flash(:error, "Unable to start game!")
        |> redirect(to: Routes.game_path(conn, :new))
    end
  end

  @spec show(conn, params) :: conn
  def show(conn, %{"id" => _game_name}) do
    conn
    |> render("show.html")
  end

  defp require_player(conn, _opts) do
    if get_session(conn, :current_player) do
      conn
    else
      conn
      |> redirect(to: Routes.session_path(conn, :new))
      |> halt()
    end
  end

  defp generate_game_name do
    name_length = 4

    name_length
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64()
    |> binary_part(0, name_length)
  end

  defp generate_auth_token(conn) do
    current_player = get_session(conn, :current_player)
    Phoenix.Token.sign(conn, "player auth", current_player)
  end
end
