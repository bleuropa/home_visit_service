defmodule HomeVisitServiceWeb.AvailableVisitsLive do
  use Phoenix.LiveView

  alias HomeVisitService.Visits

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :visits, fetch_available_visits())}
  end

  @impl true
  def handle_event("fulfill", %{"id" => visit_id}, socket) do
    IO.inspect(visit_id, label: "visit_id")
    visit = Visits.get_visit!(visit_id)
    if visit.minutes < socket.assigns.current_user.minutes do
      Visits.fulfill_visit(visit_id, socket.assigns.current_user.id)
    end

    {:noreply, assign(socket, :visits, fetch_available_visits())}
  end

  defp fetch_available_visits do
    Visits.list_available_visits()
  end

  def render(assigns) do
    ~H"""
    <div class="w-full h-screen bg-gray-900">
      <h2 class="text-white text-xl">Available Visits</h2>
      <ul class="w-full h-full p-10 bg-gray-900 divide-y divide-gray-200 dark:divide-gray-700">
        <%= for visit <- @visits do %>
        <li class="pb-3 sm:pb-4">
           <div class="flex items-center space-x-4">
              <div phx-click="fulfill" phx-value-id={visit.id} class="flex-shrink-0 hover:cursor-pointer">
                <div class="bg-gray-900 text-white rounded-full p-2">
                  <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
                  </svg>
                 </div>
              </div>
              <div class="flex-1 min-w-0">
                 <p class="text-sm font-medium text-gray-900 truncate dark:text-white">
                   <%= visit.member.first_name %> <%= visit.member.last_name %>
                 </p>
                 <p class="text-sm text-gray-500 truncate dark:text-gray-400">
                   <%= visit.special_instructions %>
                 </p>
              </div>
              <div class="flex-1 min-w-0">
                 <div class="flex">
                   <%= for {task, idx} <- Enum.with_index(visit.tasks) do %>
                     <p class="text-sm text-gray-500 truncate dark:text-gray-400">
                       <%= idx + 1 %>) <%= task.title %> | <%= task.description %>
                     </p>
                   <% end %>
                 </div>
              </div>
              <div class="inline-flex items-center text-base font-semibold text-gray-900 dark:text-white">
                 <%= visit.minutes %> minutes
              </div>
          </div>
        </li>
        <% end %>
      </ul>
    </div>
    """
  end
end
