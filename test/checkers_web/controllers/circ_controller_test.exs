defmodule CheckersWeb.CircControllerTest do
  use CheckersWeb.ConnCase

  alias Checkers.Pics
  alias Checkers.Pics.Circ

  @create_attrs %{color: "some color", rad: 42, x: 42, y: 42}
  @update_attrs %{color: "some updated color", rad: 43, x: 43, y: 43}
  @invalid_attrs %{color: nil, rad: nil, x: nil, y: nil}

  def fixture(:circ) do
    {:ok, circ} = Pics.create_circ(@create_attrs)
    circ
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all circs", %{conn: conn} do
      conn = get conn, circ_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create circ" do
    test "renders circ when data is valid", %{conn: conn} do
      conn = post conn, circ_path(conn, :create), circ: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, circ_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "color" => "some color",
        "rad" => 42,
        "x" => 42,
        "y" => 42}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, circ_path(conn, :create), circ: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update circ" do
    setup [:create_circ]

    test "renders circ when data is valid", %{conn: conn, circ: %Circ{id: id} = circ} do
      conn = put conn, circ_path(conn, :update, circ), circ: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, circ_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "color" => "some updated color",
        "rad" => 43,
        "x" => 43,
        "y" => 43}
    end

    test "renders errors when data is invalid", %{conn: conn, circ: circ} do
      conn = put conn, circ_path(conn, :update, circ), circ: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete circ" do
    setup [:create_circ]

    test "deletes chosen circ", %{conn: conn, circ: circ} do
      conn = delete conn, circ_path(conn, :delete, circ)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, circ_path(conn, :show, circ)
      end
    end
  end

  defp create_circ(_) do
    circ = fixture(:circ)
    {:ok, circ: circ}
  end
end
