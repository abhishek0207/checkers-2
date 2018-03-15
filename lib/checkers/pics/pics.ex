defmodule Checkers.Pics do
  @moduledoc """
  The Pics context.
  """

  import Ecto.Query, warn: false
  alias Checkers.Repo

  alias Checkers.Pics.Picture

  @doc """
  Returns the list of pictures.

  ## Examples

      iex> list_pictures()
      [%Picture{}, ...]

  """
  def list_pictures do
    Repo.all(Picture)
  end

  @doc """
  Gets a single picture.

  Raises `Ecto.NoResultsError` if the Picture does not exist.

  ## Examples

      iex> get_picture!(123)
      %Picture{}

      iex> get_picture!(456)
      ** (Ecto.NoResultsError)

  """
  def get_picture!(id), do: Repo.get!(Picture, id)

  @doc """
  Creates a picture.

  ## Examples

      iex> create_picture(%{field: value})
      {:ok, %Picture{}}

      iex> create_picture(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_picture(attrs \\ %{}) do
    %Picture{}
    |> Picture.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a picture.

  ## Examples

      iex> update_picture(picture, %{field: new_value})
      {:ok, %Picture{}}

      iex> update_picture(picture, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_picture(%Picture{} = picture, attrs) do
    picture
    |> Picture.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Picture.

  ## Examples

      iex> delete_picture(picture)
      {:ok, %Picture{}}

      iex> delete_picture(picture)
      {:error, %Ecto.Changeset{}}

  """
  def delete_picture(%Picture{} = picture) do
    Repo.delete(picture)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking picture changes.

  ## Examples

      iex> change_picture(picture)
      %Ecto.Changeset{source: %Picture{}}

  """
  def change_picture(%Picture{} = picture) do
    Picture.changeset(picture, %{})
  end

  alias Checkers.Pics.Circ

  @doc """
  Returns the list of circs.

  ## Examples

      iex> list_circs()
      [%Circ{}, ...]

  """
  def list_circs do
    Repo.all(Circ)
  end

  @doc """
  Gets a single circ.

  Raises `Ecto.NoResultsError` if the Circ does not exist.

  ## Examples

      iex> get_circ!(123)
      %Circ{}

      iex> get_circ!(456)
      ** (Ecto.NoResultsError)

  """
  def get_circ!(id), do: Repo.get!(Circ, id)

  @doc """
  Creates a circ.

  ## Examples

      iex> create_circ(%{field: value})
      {:ok, %Circ{}}

      iex> create_circ(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_circ(attrs \\ %{}) do
    %Circ{}
    |> Circ.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a circ.

  ## Examples

      iex> update_circ(circ, %{field: new_value})
      {:ok, %Circ{}}

      iex> update_circ(circ, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_circ(%Circ{} = circ, attrs) do
    circ
    |> Circ.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Circ.

  ## Examples

      iex> delete_circ(circ)
      {:ok, %Circ{}}

      iex> delete_circ(circ)
      {:error, %Ecto.Changeset{}}

  """
  def delete_circ(%Circ{} = circ) do
    Repo.delete(circ)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking circ changes.

  ## Examples

      iex> change_circ(circ)
      %Ecto.Changeset{source: %Circ{}}

  """
  def change_circ(%Circ{} = circ) do
    Circ.changeset(circ, %{})
  end

  alias Checkers.Pics.Rect

  @doc """
  Returns the list of rects.

  ## Examples

      iex> list_rects()
      [%Rect{}, ...]

  """
  def list_rects do
    Repo.all(Rect)
  end

  @doc """
  Gets a single rect.

  Raises `Ecto.NoResultsError` if the Rect does not exist.

  ## Examples

      iex> get_rect!(123)
      %Rect{}

      iex> get_rect!(456)
      ** (Ecto.NoResultsError)

  """
  def get_rect!(id), do: Repo.get!(Rect, id)

  @doc """
  Creates a rect.

  ## Examples

      iex> create_rect(%{field: value})
      {:ok, %Rect{}}

      iex> create_rect(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_rect(attrs \\ %{}) do
    %Rect{}
    |> Rect.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a rect.

  ## Examples

      iex> update_rect(rect, %{field: new_value})
      {:ok, %Rect{}}

      iex> update_rect(rect, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_rect(%Rect{} = rect, attrs) do
    rect
    |> Rect.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Rect.

  ## Examples

      iex> delete_rect(rect)
      {:ok, %Rect{}}

      iex> delete_rect(rect)
      {:error, %Ecto.Changeset{}}

  """
  def delete_rect(%Rect{} = rect) do
    Repo.delete(rect)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking rect changes.

  ## Examples

      iex> change_rect(rect)
      %Ecto.Changeset{source: %Rect{}}

  """
  def change_rect(%Rect{} = rect) do
    Rect.changeset(rect, %{})
  end
end
