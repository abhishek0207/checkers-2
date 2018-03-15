defmodule Checkers.Pics.Circ do
  use Ecto.Schema
  import Ecto.Changeset


  schema "circs" do
    field :color, :string
    field :rad, :integer
    field :x, :integer
    field :y, :integer

    timestamps()
  end

  @doc false
  def changeset(circ, attrs) do
    circ
    |> cast(attrs, [:x, :y, :rad, :color])
    |> validate_required([:x, :y, :rad, :color])
  end
end
