defmodule HomeVisitServiceWeb.LiveAuth do
  import Phoenix.LiveView
  alias HomeVisitService.Accounts

  def on_mount(:ensure_authenticated, _params, session, socket) do
    socket = mount_current_user(session, socket)

    if socket.assigns.current_user do
      {:cont, socket}
    else
      socket =
        socket
        |> Phoenix.LiveView.put_flash(:error, "You must log in to access this page.")
        |> Phoenix.LiveView.redirect(to: "/users/log_in")

      {:halt, socket}
    end
  end

  def on_mount(:maybe_user, _params, session, socket) do
    socket =
      if session["user_token"] do
        mount_current_user(session, socket)
      else
        socket
      end

    {:cont, socket}
  end

  defp mount_current_user(session, socket) do
    user = Accounts.get_user_by_session_token(session["user_token"])
    assign(socket, :current_user, user)
  end
end
