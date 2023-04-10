defmodule HomeVisitService.Tasks.Task do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tasks" do
    field :title, :string
    field :description, :string
    field :temp_id, :string, virtual: true
    field :delete, :boolean, virtual: true

    belongs_to :visit, HomeVisitService.Visits.Visit

    timestamps()
  end

  def changeset(task, attrs) do
    task
    # So its persisted
    |> Map.put(:temp_id, task.temp_id || attrs["temp_id"])
    |> cast(attrs, [:title, :description, :delete])
    |> validate_required([:title, :description])
    |> maybe_mark_for_deletion()
  end

  defp maybe_mark_for_deletion(%{data: %{id: nil}} = changeset), do: changeset

  defp maybe_mark_for_deletion(changeset) do
    if get_change(changeset, :delete) do
      %{changeset | action: :delete}
    else
      changeset
    end
  end
end
