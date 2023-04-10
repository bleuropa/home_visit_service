defmodule HomeVisitService.VisitsTest do
  use HomeVisitService.DataCase

  alias HomeVisitService.Visits

  describe "visits" do
    alias HomeVisitService.Visits.Visit

    import HomeVisitService.VisitsFixtures

    @invalid_attrs %{date: nil, minutes: nil, tasks: nil}

    test "list_visits/0 returns all visits" do
      visit = visit_fixture()
      assert Visits.list_visits() == [visit]
    end

    test "get_visit!/1 returns the visit with given id" do
      visit = visit_fixture()
      assert Visits.get_visit!(visit.id) == visit
    end

    test "create_visit/1 with valid data creates a visit" do
      valid_attrs = %{date: ~U[2023-04-07 01:43:00Z], minutes: 42, tasks: "some tasks"}

      assert {:ok, %Visit{} = visit} = Visits.create_visit(valid_attrs)
      assert visit.date == ~U[2023-04-07 01:43:00Z]
      assert visit.minutes == 42
      assert visit.tasks == "some tasks"
    end

    test "create_visit/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Visits.create_visit(@invalid_attrs)
    end

    test "update_visit/2 with valid data updates the visit" do
      visit = visit_fixture()
      update_attrs = %{date: ~U[2023-04-08 01:43:00Z], minutes: 43, tasks: "some updated tasks"}

      assert {:ok, %Visit{} = visit} = Visits.update_visit(visit, update_attrs)
      assert visit.date == ~U[2023-04-08 01:43:00Z]
      assert visit.minutes == 43
      assert visit.tasks == "some updated tasks"
    end

    test "update_visit/2 with invalid data returns error changeset" do
      visit = visit_fixture()
      assert {:error, %Ecto.Changeset{}} = Visits.update_visit(visit, @invalid_attrs)
      assert visit == Visits.get_visit!(visit.id)
    end

    test "delete_visit/1 deletes the visit" do
      visit = visit_fixture()
      assert {:ok, %Visit{}} = Visits.delete_visit(visit)
      assert_raise Ecto.NoResultsError, fn -> Visits.get_visit!(visit.id) end
    end

    test "change_visit/1 returns a visit changeset" do
      visit = visit_fixture()
      assert %Ecto.Changeset{} = Visits.change_visit(visit)
    end
  end
end
