defmodule CheckersWeb.PageController do
  use CheckersWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
  def game(conn, params) do
    render conn, "game.html", game: params["game"]
  end
  def test(conn, %{"name" => name}) do
    {:ok, _pid} = CheckersWeb.Game.start_link(name)
    conn
    |> put_flash(:info, "You entered the name: " <> name)
    |> render("index.html")
    end
end
