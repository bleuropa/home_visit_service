defmodule HomeVisitServiceWeb.VisitLiveTest do
  use HomeVisitServiceWeb.ConnCase

  import Phoenix.LiveViewTest
  import HomeVisitService.VisitsFixtures

  @create_attrs %{date: %{day: 7, hour: 1, minute: 43, month: 4, year: 2023}, minutes: 42, tasks: "some tasks"}
  @update_attrs %{date: %{day: 8, hour: 1, minute: 43, month: 4, year: 2023}, minutes: 43, tasks: "some updated tasks"}
  @invalid_attrs %{date: %{day: 30, hour: 1, minute: 43, month: 2, year: 2023}, minutes: nil, tasks: nil}

  defp create_visit(_) do
    visit = visit_fixture()
    %{visit: visit}
  end

  describe "Index" do
    setup [:create_visit]

    test "lists all visits", %{conn: conn, visit: visit} do
      {:ok, _index_live, html} = live(conn, Routes.visit_index_path(conn, :index))

      assert html =~ "Listing Visits"
      assert html =~ visit.tasks
    end

    test "saves new visit", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.visit_index_path(conn, :index))

      assert index_live |> element("a", "New Visit") |> render_click() =~
               "New Visit"

      assert_patch(index_live, Routes.visit_index_path(conn, :new))

      assert index_live
             |> form("#visit-form", visit: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        index_live
        |> form("#visit-form", visit: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.visit_index_path(conn, :index))

      assert html =~ "Visit created successfully"
      assert html =~ "some tasks"
    end

    test "updates visit in listing", %{conn: conn, visit: visit} do
      {:ok, index_live, _html} = live(conn, Routes.visit_index_path(conn, :index))

      assert index_live |> element("#visit-#{visit.id} a", "Edit") |> render_click() =~
               "Edit Visit"

      assert_patch(index_live, Routes.visit_index_path(conn, :edit, visit))

      assert index_live
             |> form("#visit-form", visit: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        index_live
        |> form("#visit-form", visit: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.visit_index_path(conn, :index))

      assert html =~ "Visit updated successfully"
      assert html =~ "some updated tasks"
    end

    test "deletes visit in listing", %{conn: conn, visit: visit} do
      {:ok, index_live, _html} = live(conn, Routes.visit_index_path(conn, :index))

      assert index_live |> element("#visit-#{visit.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#visit-#{visit.id}")
    end
  end

  describe "Show" do
    setup [:create_visit]

    test "displays visit", %{conn: conn, visit: visit} do
      {:ok, _show_live, html} = live(conn, Routes.visit_show_path(conn, :show, visit))

      assert html =~ "Show Visit"
      assert html =~ visit.tasks
    end

    test "updates visit within modal", %{conn: conn, visit: visit} do
      {:ok, show_live, _html} = live(conn, Routes.visit_show_path(conn, :show, visit))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Visit"

      assert_patch(show_live, Routes.visit_show_path(conn, :edit, visit))

      assert show_live
             |> form("#visit-form", visit: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        show_live
        |> form("#visit-form", visit: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.visit_show_path(conn, :show, visit))

      assert html =~ "Visit updated successfully"
      assert html =~ "some updated tasks"
    end
  end
end
