defmodule HomeVisitService.Tasks do
  import Ecto.Query
  alias HomeVisitService.Repo
  alias HomeVisitService.Tasks.Task

  def list_tasks(user_id) do
    Repo.all(
      from t in Task,
      where: t.user_id == ^user_id)
  end

  def get_task!(id), do: Repo.get!(Task, id)

  def create_task(attrs \\ %{}) do
    %Task{}
    |> Task.changeset(attrs)
    |> Repo.insert()
  end

  def change_task(task, attrs \\ %{}) do
    Task.changeset(task, attrs)
  end
end
