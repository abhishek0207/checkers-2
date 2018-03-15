defmodule CheckersWeb.RectController do
  use CheckersWeb, :controller

  alias Checkers.Pics
  alias Checkers.Pics.Rect

  action_fallback CheckersWeb.FallbackController

  def index(conn, _params) do
    rects = Pics.list_rects()
    render(conn, "index.json", rects: rects)
  end

  def create(conn, %{"rect" => rect_params}) do
    with {:ok, %Rect{} = rect} <- Pics.create_rect(rect_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", rect_path(conn, :show, rect))
      |> render("show.json", rect: rect)
    end
  end

  def show(conn, %{"id" => id}) do
    rect = Pics.get_rect!(id)
    render(conn, "show.json", rect: rect)
  end

  def update(conn, %{"id" => id, "rect" => rect_params}) do
    rect = Pics.get_rect!(id)

    with {:ok, %Rect{} = rect} <- Pics.update_rect(rect, rect_params) do
      render(conn, "show.json", rect: rect)
    end
  end

  def delete(conn, %{"id" => id}) do
    rect = Pics.get_rect!(id)
    with {:ok, %Rect{}} <- Pics.delete_rect(rect) do
      send_resp(conn, :no_content, "")
    end
  end
end
