defmodule HomeVisitService.Visits.Visit do
  use Ecto.Schema
  import Ecto.Changeset
  alias HomeVisitService.Tasks.Task

  schema "visits" do
    field :date, :date
    field :minutes, :float
    field :special_instructions, :string
    field :status, :string, default: "pending"
    has_many :tasks, Task
    belongs_to :member, HomeVisitService.Accounts.User, foreign_key: :member_id
    belongs_to :pal, HomeVisitService.Accounts.User, foreign_key: :pal_id

    timestamps()
  end

  @doc false
  def changeset(visit, attrs) do
    visit
    |> cast(attrs, [:date, :minutes, :status, :special_instructions, :member_id])
    |> validate_required([:date, :minutes])
    |> cast_assoc(:tasks, with: &Task.changeset/2)
  end

  def claim_changeset(visit, attrs) do
    visit
    |> cast(attrs, [:pal_id])
    |> validate_required([:pal_id])
  end
end
