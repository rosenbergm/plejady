defmodule PlejadyWeb.TestLiveTest do
  use PlejadyWeb.ConnCase

  import Phoenix.LiveViewTest
  import Plejady.TestingFixtures

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  defp create_test(_) do
    test = test_fixture()
    %{test: test}
  end

  describe "Index" do
    setup [:create_test]

    test "lists all test", %{conn: conn, test: test} do
      {:ok, _index_live, html} = live(conn, ~p"/test")

      assert html =~ "Listing Test"
      assert html =~ test.name
    end

    test "saves new test", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/test")

      assert index_live |> element("a", "New Test") |> render_click() =~
               "New Test"

      assert_patch(index_live, ~p"/test/new")

      assert index_live
             |> form("#test-form", test: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#test-form", test: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/test")

      html = render(index_live)
      assert html =~ "Test created successfully"
      assert html =~ "some name"
    end

    test "updates test in listing", %{conn: conn, test: test} do
      {:ok, index_live, _html} = live(conn, ~p"/test")

      assert index_live |> element("#test-#{test.id} a", "Edit") |> render_click() =~
               "Edit Test"

      assert_patch(index_live, ~p"/test/#{test}/edit")

      assert index_live
             |> form("#test-form", test: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#test-form", test: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/test")

      html = render(index_live)
      assert html =~ "Test updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes test in listing", %{conn: conn, test: test} do
      {:ok, index_live, _html} = live(conn, ~p"/test")

      assert index_live |> element("#test-#{test.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#test-#{test.id}")
    end
  end

  describe "Show" do
    setup [:create_test]

    test "displays test", %{conn: conn, test: test} do
      {:ok, _show_live, html} = live(conn, ~p"/test/#{test}")

      assert html =~ "Show Test"
      assert html =~ test.name
    end

    test "updates test within modal", %{conn: conn, test: test} do
      {:ok, show_live, _html} = live(conn, ~p"/test/#{test}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Test"

      assert_patch(show_live, ~p"/test/#{test}/show/edit")

      assert show_live
             |> form("#test-form", test: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#test-form", test: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/test/#{test}")

      html = render(show_live)
      assert html =~ "Test updated successfully"
      assert html =~ "some updated name"
    end
  end
end
