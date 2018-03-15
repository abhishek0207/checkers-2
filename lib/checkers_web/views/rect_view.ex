defmodule CheckersWeb.RectView do
  use CheckersWeb, :view
  alias CheckersWeb.RectView

  def render("index.json", %{rects: rects}) do
    %{data: render_many(rects, RectView, "rect.json")}
  end

  def render("show.json", %{rect: rect}) do
    %{data: render_one(rect, RectView, "rect.json")}
  end

  def render("rect.json", %{rect: rect}) do
    %{id: rect.id,
      x: rect.x,
      y: rect.y,
      w: rect.w,
      h: rect.h,
      color: rect.color}
  end
end
