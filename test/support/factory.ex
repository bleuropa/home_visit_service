defmodule HomeVisitService.Factory do
  use ExMachina

  def user_factory do
    %HomeVisitService.Accounts.User{
      email: sequence(:email, &"user-#{&1}@example.com"),
      first_name: "John",
      last_name: "217",
      password: "password123",
      role: "member"
    }
  end
end
