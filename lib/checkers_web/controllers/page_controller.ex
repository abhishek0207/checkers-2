defmodule CheckersWeb.PageController do
  use CheckersWeb, :controller

  def index(conn, _params) do
    render conn, "index.html", id: Checkers.generate_player_id
  end
  def game(conn, params) do
    render conn, "game.html", game: params["game"]
  end
end
