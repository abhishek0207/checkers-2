defmodule CheckersWeb.CircController do
  use CheckersWeb, :controller

  alias Checkers.Pics
  alias Checkers.Pics.Circ

  action_fallback CheckersWeb.FallbackController

  def index(conn, _params) do
    circs = Pics.list_circs()
    render(conn, "index.json", circs: circs)
  end

  def create(conn, %{"circ" => circ_params}) do
    with {:ok, %Circ{} = circ} <- Pics.create_circ(circ_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", circ_path(conn, :show, circ))
      |> render("show.json", circ: circ)
    end
  end

  def show(conn, %{"id" => id}) do
    circ = Pics.get_circ!(id)
    render(conn, "show.json", circ: circ)
  end

  def update(conn, %{"id" => id, "circ" => circ_params}) do
    circ = Pics.get_circ!(id)

    with {:ok, %Circ{} = circ} <- Pics.update_circ(circ, circ_params) do
      render(conn, "show.json", circ: circ)
    end
  end

  def delete(conn, %{"id" => id}) do
    circ = Pics.get_circ!(id)
    with {:ok, %Circ{}} <- Pics.delete_circ(circ) do
      send_resp(conn, :no_content, "")
    end
  end
end
