defmodule HomeVisitService.VisitsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `HomeVisitService.Visits` context.
  """

  @doc """
  Generate a visit.
  """
  def visit_fixture(attrs \\ %{}) do
    {:ok, visit} =
      attrs
      |> Enum.into(%{
        date: ~U[2023-04-07 01:43:00Z],
        minutes: 42,
        tasks: "some tasks"
      })
      |> HomeVisitService.Visits.create_visit()

    visit
  end
end
