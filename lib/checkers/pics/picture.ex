defmodule Checkers.Pics.Picture do
  use Ecto.Schema
  import Ecto.Changeset


  schema "pictures" do
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(picture, attrs) do
    picture
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
