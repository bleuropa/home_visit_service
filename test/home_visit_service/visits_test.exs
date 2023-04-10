defmodule HomeVisitService.VisitsTest do
  use HomeVisitService.DataCase

  alias HomeVisitService.Visits
  alias HomeVisitService.Factory

  describe "Task creation within a visit request" do
    setup do
      member = Factory.insert(:user, %{role: "member"})
      {:ok, %{member: member}}
    end

    test "successfully creates tasks within a visit request", %{member: member} do
      visit_params = %{
        "date" => "2023-04-13",
        "minutes" => "100",
        "special_instructions" => "Some instructions",
        "tasks" => %{
          "0" => %{
            "description" => "Task description",
            "title" => "Task title"
          }
        }
      }

      {:ok, visit} = Visits.create_visit_request(member.id, visit_params)

      tasks = visit |> Repo.preload(:tasks) |> Map.get(:tasks)

      assert length(tasks) == 1
      assert tasks |> Enum.at(0) |> Map.get(:title) == "Task title"
      assert tasks |> Enum.at(0) |> Map.get(:description) == "Task description"
    end
  end

  describe "Fulfilling a visit request" do
    setup do
      member = insert(:user, %{role: "member", minutes: 100})
      pal = insert(:user, %{role: "pal", minutes: 0})
      visit = insert(:visit, %{member: member, status: "pending", minutes: 50})

      {:ok, %{member: member, pal: pal, visit: visit}}
    end

    test "successfully fulfills a visit request", %{member: member, pal: pal, visit: visit} do
      assert {:ok, updated_visit} = Visits.fulfill_visit(visit.id, pal.id)

      updated_member = Repo.get(HomeVisitService.Accounts.User, member.id)
      updated_pal = Repo.get(HomeVisitService.Accounts.User, pal.id)
      updated_visit = Repo.get(Visits.Visit, visit.id)

      IO.inspect(updated_visit, label: "updated visit")
      assert updated_visit.status == "fulfilled"
      assert updated_visit.pal_id == pal.id
      assert updated_member.minutes == 50
      assert updated_pal.minutes == 42.5
    end

    test "Only pending visits are fetched for pals" do
      # Create visits with different statuses
      insert(:visit, status: "pending")
      insert(:visit, status: "fulfilled")
      insert(:visit, status: "pending")
      insert(:visit, status: "cancelled")

      # Fetch visits for pals
      fetched_visits = Visits.list_available_visits()

      # Assert that only pending visits are fetched
      assert Enum.all?(fetched_visits, fn visit -> visit.status == "pending" end)
    end

  end

end
