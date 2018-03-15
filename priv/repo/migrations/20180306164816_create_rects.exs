defmodule Checkers.Repo.Migrations.CreateRects do
  use Ecto.Migration

  def change do
    create table(:rects) do
      add :x, :integer
      add :y, :integer
      add :w, :integer
      add :h, :integer
      add :color, :string

      timestamps()
    end

  end
end
