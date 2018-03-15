defmodule CheckersWeb.CircView do
  use CheckersWeb, :view
  alias CheckersWeb.CircView

  def render("index.json", %{circs: circs}) do
    %{data: render_many(circs, CircView, "circ.json")}
  end

  def render("show.json", %{circ: circ}) do
    %{data: render_one(circ, CircView, "circ.json")}
  end

  def render("circ.json", %{circ: circ}) do
    %{id: circ.id,
      x: circ.x,
      y: circ.y,
      rad: circ.rad,
      color: circ.color}
  end
end
