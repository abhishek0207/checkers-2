defmodule Checkers.Pics.Rect do
  use Ecto.Schema
  import Ecto.Changeset


  schema "rects" do
    field :color, :string
    field :h, :integer
    field :w, :integer
    field :x, :integer
    field :y, :integer

    timestamps()
  end

  @doc false
  def changeset(rect, attrs) do
    rect
    |> cast(attrs, [:x, :y, :w, :h, :color])
    |> validate_required([:x, :y, :w, :h, :color])
  end
end
