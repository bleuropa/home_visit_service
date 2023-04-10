defmodule HomeVisitServiceWeb.VisitLive.Index do
  use HomeVisitServiceWeb, :live_view

  alias HomeVisitService.Visits
  alias HomeVisitService.Visits.Visit

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :visits, list_visits())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Visit")
    |> assign(:visit, Visits.get_visit!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Visit")
    |> assign(:visit, %Visit{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Visits")
    |> assign(:visit, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    visit = Visits.get_visit!(id)
    {:ok, _} = Visits.delete_visit(visit)

    {:noreply, assign(socket, :visits, list_visits())}
  end

  defp list_visits do
    Visits.list_visits()
  end
end
