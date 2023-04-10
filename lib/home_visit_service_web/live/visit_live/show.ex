defmodule HomeVisitServiceWeb.VisitLive.Show do
  use HomeVisitServiceWeb, :live_view

  alias HomeVisitService.Visits

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:visit, Visits.get_visit!(id))}
  end

  defp page_title(:show), do: "Show Visit"
  defp page_title(:edit), do: "Edit Visit"
end
