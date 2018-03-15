defmodule CheckersWeb.RectControllerTest do
  use CheckersWeb.ConnCase

  alias Checkers.Pics
  alias Checkers.Pics.Rect

  @create_attrs %{color: "some color", h: 42, w: 42, x: 42, y: 42}
  @update_attrs %{color: "some updated color", h: 43, w: 43, x: 43, y: 43}
  @invalid_attrs %{color: nil, h: nil, w: nil, x: nil, y: nil}

  def fixture(:rect) do
    {:ok, rect} = Pics.create_rect(@create_attrs)
    rect
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all rects", %{conn: conn} do
      conn = get conn, rect_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create rect" do
    test "renders rect when data is valid", %{conn: conn} do
      conn = post conn, rect_path(conn, :create), rect: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, rect_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "color" => "some color",
        "h" => 42,
        "w" => 42,
        "x" => 42,
        "y" => 42}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, rect_path(conn, :create), rect: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update rect" do
    setup [:create_rect]

    test "renders rect when data is valid", %{conn: conn, rect: %Rect{id: id} = rect} do
      conn = put conn, rect_path(conn, :update, rect), rect: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, rect_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "color" => "some updated color",
        "h" => 43,
        "w" => 43,
        "x" => 43,
        "y" => 43}
    end

    test "renders errors when data is invalid", %{conn: conn, rect: rect} do
      conn = put conn, rect_path(conn, :update, rect), rect: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete rect" do
    setup [:create_rect]

    test "deletes chosen rect", %{conn: conn, rect: rect} do
      conn = delete conn, rect_path(conn, :delete, rect)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, rect_path(conn, :show, rect)
      end
    end
  end

  defp create_rect(_) do
    rect = fixture(:rect)
    {:ok, rect: rect}
  end
end
