defmodule Checkers.PicsTest do
  use Checkers.DataCase

  alias Checkers.Pics

  describe "pictures" do
    alias Checkers.Pics.Picture

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def picture_fixture(attrs \\ %{}) do
      {:ok, picture} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Pics.create_picture()

      picture
    end

    test "list_pictures/0 returns all pictures" do
      picture = picture_fixture()
      assert Pics.list_pictures() == [picture]
    end

    test "get_picture!/1 returns the picture with given id" do
      picture = picture_fixture()
      assert Pics.get_picture!(picture.id) == picture
    end

    test "create_picture/1 with valid data creates a picture" do
      assert {:ok, %Picture{} = picture} = Pics.create_picture(@valid_attrs)
      assert picture.name == "some name"
    end

    test "create_picture/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Pics.create_picture(@invalid_attrs)
    end

    test "update_picture/2 with valid data updates the picture" do
      picture = picture_fixture()
      assert {:ok, picture} = Pics.update_picture(picture, @update_attrs)
      assert %Picture{} = picture
      assert picture.name == "some updated name"
    end

    test "update_picture/2 with invalid data returns error changeset" do
      picture = picture_fixture()
      assert {:error, %Ecto.Changeset{}} = Pics.update_picture(picture, @invalid_attrs)
      assert picture == Pics.get_picture!(picture.id)
    end

    test "delete_picture/1 deletes the picture" do
      picture = picture_fixture()
      assert {:ok, %Picture{}} = Pics.delete_picture(picture)
      assert_raise Ecto.NoResultsError, fn -> Pics.get_picture!(picture.id) end
    end

    test "change_picture/1 returns a picture changeset" do
      picture = picture_fixture()
      assert %Ecto.Changeset{} = Pics.change_picture(picture)
    end
  end

  describe "circs" do
    alias Checkers.Pics.Circ

    @valid_attrs %{color: "some color", rad: 42, x: 42, y: 42}
    @update_attrs %{color: "some updated color", rad: 43, x: 43, y: 43}
    @invalid_attrs %{color: nil, rad: nil, x: nil, y: nil}

    def circ_fixture(attrs \\ %{}) do
      {:ok, circ} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Pics.create_circ()

      circ
    end

    test "list_circs/0 returns all circs" do
      circ = circ_fixture()
      assert Pics.list_circs() == [circ]
    end

    test "get_circ!/1 returns the circ with given id" do
      circ = circ_fixture()
      assert Pics.get_circ!(circ.id) == circ
    end

    test "create_circ/1 with valid data creates a circ" do
      assert {:ok, %Circ{} = circ} = Pics.create_circ(@valid_attrs)
      assert circ.color == "some color"
      assert circ.rad == 42
      assert circ.x == 42
      assert circ.y == 42
    end

    test "create_circ/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Pics.create_circ(@invalid_attrs)
    end

    test "update_circ/2 with valid data updates the circ" do
      circ = circ_fixture()
      assert {:ok, circ} = Pics.update_circ(circ, @update_attrs)
      assert %Circ{} = circ
      assert circ.color == "some updated color"
      assert circ.rad == 43
      assert circ.x == 43
      assert circ.y == 43
    end

    test "update_circ/2 with invalid data returns error changeset" do
      circ = circ_fixture()
      assert {:error, %Ecto.Changeset{}} = Pics.update_circ(circ, @invalid_attrs)
      assert circ == Pics.get_circ!(circ.id)
    end

    test "delete_circ/1 deletes the circ" do
      circ = circ_fixture()
      assert {:ok, %Circ{}} = Pics.delete_circ(circ)
      assert_raise Ecto.NoResultsError, fn -> Pics.get_circ!(circ.id) end
    end

    test "change_circ/1 returns a circ changeset" do
      circ = circ_fixture()
      assert %Ecto.Changeset{} = Pics.change_circ(circ)
    end
  end

  describe "rects" do
    alias Checkers.Pics.Rect

    @valid_attrs %{color: "some color", h: 42, w: 42, x: 42, y: 42}
    @update_attrs %{color: "some updated color", h: 43, w: 43, x: 43, y: 43}
    @invalid_attrs %{color: nil, h: nil, w: nil, x: nil, y: nil}

    def rect_fixture(attrs \\ %{}) do
      {:ok, rect} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Pics.create_rect()

      rect
    end

    test "list_rects/0 returns all rects" do
      rect = rect_fixture()
      assert Pics.list_rects() == [rect]
    end

    test "get_rect!/1 returns the rect with given id" do
      rect = rect_fixture()
      assert Pics.get_rect!(rect.id) == rect
    end

    test "create_rect/1 with valid data creates a rect" do
      assert {:ok, %Rect{} = rect} = Pics.create_rect(@valid_attrs)
      assert rect.color == "some color"
      assert rect.h == 42
      assert rect.w == 42
      assert rect.x == 42
      assert rect.y == 42
    end

    test "create_rect/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Pics.create_rect(@invalid_attrs)
    end

    test "update_rect/2 with valid data updates the rect" do
      rect = rect_fixture()
      assert {:ok, rect} = Pics.update_rect(rect, @update_attrs)
      assert %Rect{} = rect
      assert rect.color == "some updated color"
      assert rect.h == 43
      assert rect.w == 43
      assert rect.x == 43
      assert rect.y == 43
    end

    test "update_rect/2 with invalid data returns error changeset" do
      rect = rect_fixture()
      assert {:error, %Ecto.Changeset{}} = Pics.update_rect(rect, @invalid_attrs)
      assert rect == Pics.get_rect!(rect.id)
    end

    test "delete_rect/1 deletes the rect" do
      rect = rect_fixture()
      assert {:ok, %Rect{}} = Pics.delete_rect(rect)
      assert_raise Ecto.NoResultsError, fn -> Pics.get_rect!(rect.id) end
    end

    test "change_rect/1 returns a rect changeset" do
      rect = rect_fixture()
      assert %Ecto.Changeset{} = Pics.change_rect(rect)
    end
  end
end
