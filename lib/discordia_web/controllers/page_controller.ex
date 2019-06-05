defmodule DiscordiaWeb.PageController do
  use DiscordiaWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
