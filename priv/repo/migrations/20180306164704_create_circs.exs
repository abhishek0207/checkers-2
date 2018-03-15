defmodule Checkers.Repo.Migrations.CreateCircs do
  use Ecto.Migration

  def change do
    create table(:circs) do
      add :x, :integer
      add :y, :integer
      add :rad, :integer
      add :color, :string

      timestamps()
    end

  end
end
