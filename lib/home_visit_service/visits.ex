defmodule HomeVisitService.Visits do
  @moduledoc """
  The Visits context.
  """

  import Ecto.Query, warn: false
  alias HomeVisitService.Repo

  alias HomeVisitService.Accounts.User
  alias HomeVisitService.Visits.Visit
  alias HomeVisitService.Tasks.Task

  @doc """
  Returns the list of visits.

  ## Examples

      iex> list_visits()
      [%Visit{}, ...]

  """
  def list_visits do
    Repo.all(Visit)
  end

  @doc """
  Gets a single visit.

  Raises `Ecto.NoResultsError` if the Visit does not exist.

  ## Examples

      iex> get_visit!(123)
      %Visit{}

      iex> get_visit!(456)
      ** (Ecto.NoResultsError)

  """
  def get_visit!(id) do
    Repo.get!(Visit, id) |> Repo.preload(tasks: from(t in Task, order_by: t.id))
  end
  @doc """
  Updates a visit.

  ## Examples

      iex> update_visit(visit, %{field: new_value})
      {:ok, %Visit{}}

      iex> update_visit(visit, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_visit(%Visit{} = visit, attrs) do
    visit
    |> Visit.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a visit.

  ## Examples

      iex> delete_visit(visit)
      {:ok, %Visit{}}

      iex> delete_visit(visit)
      {:error, %Ecto.Changeset{}}

  """
  def delete_visit(%Visit{} = visit) do
    Repo.delete(visit)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking visit changes.

  ## Examples

      iex> change_visit(visit)
      %Ecto.Changeset{data: %Visit{}}

  """
  def change_visit(%Visit{} = visit, attrs \\ %{}) do
    Visit.changeset(visit, attrs)
  end

  def list_available_visits do
    from(v in Visit, where: v.status == "pending" and is_nil(v.pal_id))
    |> Repo.all()
    |> Repo.preload([:member, :tasks])
  end
  def list_member_visits(member_id) do
    from(v in Visit, where: v.member_id == ^member_id, limit: 10)
    |> Repo.all()
    |> IO.inspect(label: "member visits")
  end

  def list_pal_fulfilled_visits(pal_id) do
    from(v in Visit, where: v.pal_id == ^pal_id and v.status == "fulfilled")
    |> Repo.all()
  end

  def cancel_visit_request(visit_id) do
    visit = Repo.get!(Visit, visit_id)

    if visit.status == "pending" do
      changeset = Visit.changeset(visit, %{status: "canceled"})
      Repo.update(changeset)
    else
      {:error, "Visit cannot be canceled"}
    end
  end

  def create_visit_request(member_id, visit_params) do
    IO.inspect(visit_params, label: "visit_params")
    member = Repo.get!(User, member_id)

    changeset =
      %Visit{}
      |> Visit.changeset(visit_params)
      |> Ecto.Changeset.put_change(:status, "pending")
      |> Ecto.Changeset.put_change(:member_id, member.id)

    IO.inspect(changeset, label: "changeset")

    Repo.insert(changeset)
  end

  def fulfill_visit(visit_id, pal_id) do
    visit = Repo.get!(Visit, visit_id)
    member = Repo.get!(User, visit.member_id)
    pal = Repo.get!(User, pal_id)

    IO.inspect(visit, label: "visit")

    if visit.status == "pending" and member.minutes >= visit.minutes do
      member_new_minutes = member.minutes - visit.minutes
      pal_new_minutes = pal.minutes + visit.minutes * 0.85

      multi =
        Ecto.Multi.new()
        |> Ecto.Multi.update(:update_member_minutes, update_user_minutes_changeset(member, member_new_minutes))
        |> Ecto.Multi.update(:update_pal_minutes, update_user_minutes_changeset(pal, pal_new_minutes))
        |> Ecto.Multi.update(:fulfill_visit, Visit.changeset(visit, %{status: "fulfilled"}))
        |> Ecto.Multi.update(:claim_visit, Visit.claim_changeset(visit, %{pal_id: pal_id}))

      case Repo.transaction(multi) do
        {:ok, resp} ->
          IO.inspect(resp, label: "resp")
          {:ok, "Visit fulfilled and claimed"}
        {:error, failed_operation, failed_value, changes_so_far} ->
           IO.inspect(failed_operation, label: "failed_operation")
           IO.inspect(failed_value, label: "failed_value")

           {:error, "Failed to update user minutes or visit status"}
      end
    else
      {:error, "Invalid visit status or insufficient member minutes"}
    end
  end

  defp update_user_minutes_changeset(user, new_minutes) do
    user
    |> User.minutes_changeset(%{minutes: new_minutes})
  end
end
