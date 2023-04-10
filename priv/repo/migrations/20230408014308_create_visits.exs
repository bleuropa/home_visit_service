defmodule HomeVisitService.Repo.Migrations.CreateVisits do
  use Ecto.Migration

  def change do
    create table(:visits) do
      add :date, :date
      add :minutes, :float
      add :status, :string, default: "pending"
      add :special_instructions, :text
      add :pal_id, references(:users, on_delete: :nothing)
      add :member_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create table(:tasks) do
      add :title, :string
      add :description, :string
      add :visit_id, references(:visits, on_delete: :nothing)

      timestamps()
    end

    create index(:visits, [:member_id])
    create index(:visits, [:pal_id])
  end
end
