defmodule CheckersWeb.PictureController do
  use CheckersWeb, :controller

  alias Checkers.Pics
  alias Checkers.Pics.Picture

  def index(conn, _params) do
    pictures = Pics.list_pictures()
    render(conn, "index.html", pictures: pictures)
  end

  def new(conn, _params) do
    changeset = Pics.change_picture(%Picture{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"picture" => picture_params}) do
    case Pics.create_picture(picture_params) do
      {:ok, picture} ->
        conn
        |> put_flash(:info, "Picture created successfully.")
        |> redirect(to: picture_path(conn, :show, picture))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    picture = Pics.get_picture!(id)
    render(conn, "show.html", picture: picture)
  end

  def edit(conn, %{"id" => id}) do
    picture = Pics.get_picture!(id)
    changeset = Pics.change_picture(picture)
    render(conn, "edit.html", picture: picture, changeset: changeset)
  end

  def update(conn, %{"id" => id, "picture" => picture_params}) do
    picture = Pics.get_picture!(id)

    case Pics.update_picture(picture, picture_params) do
      {:ok, picture} ->
        conn
        |> put_flash(:info, "Picture updated successfully.")
        |> redirect(to: picture_path(conn, :show, picture))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", picture: picture, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    picture = Pics.get_picture!(id)
    {:ok, _picture} = Pics.delete_picture(picture)

    conn
    |> put_flash(:info, "Picture deleted successfully.")
    |> redirect(to: picture_path(conn, :index))
  end
end
