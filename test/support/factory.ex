defmodule HomeVisitService.Factory do
  use ExMachina.Ecto, repo: HomeVisitService.Repo
  def user_factory do
    %HomeVisitService.Accounts.User{
      email: sequence(:email, &"user-#{&1}@example.com"),
      first_name: "John",
      last_name: "217",
      hashed_password: Bcrypt.hash_pwd_salt("password"),
      password: "password123456778",
      role: "member"
    }
  end

  def visit_factory do
    member = insert(:user, %{role: "member"})
    %HomeVisitService.Visits.Visit{
      date: ~D[2023-04-13],
      minutes: 100,
      special_instructions: "Some instructions",
      status: "pending",
      member: member,
      pal: nil
    }
  end
end
