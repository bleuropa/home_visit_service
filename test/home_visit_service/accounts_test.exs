defmodule HomeVisitService.AccountsTest do
  use HomeVisitService.DataCase

  alias HomeVisitService.Accounts
  alias HomeVisitService.Factory
  alias HomeVisitService.Accounts.{User, UserToken}


  describe "User registration" do
    test "successful registration for a member" do
      user_params = params_for(:user, role: "member")
      {:ok, user} = Accounts.register_user(user_params)

      assert user.email == user_params.email
      assert user.role == "member"
    end

    test "successful registration for a pal" do
      attrs = params_for(:user, role: "pal")
      {:ok, user} = Accounts.register_user(attrs)

      assert user.email == attrs.email
      assert user.role == "pal"
    end
  end
end
