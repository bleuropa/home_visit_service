defmodule HomeVisitServiceWeb.VisitRequestLive do
  use HomeVisitServiceWeb, :live_view

  alias HomeVisitService.{Accounts, Tasks, Visits}
  alias HomeVisitService.Visits.Visit
  alias HomeVisitService.Tasks.Task

  @impl true
  def mount(_params, _, %{assigns: %{current_user: current_user}} = socket) do
    {:ok,
     socket
     |> assign(:user, current_user)
     |> assign(:visit_request_changeset, Visits.change_visit(%Visit{}, %{}))
     |> assign(:minutes, current_user.minutes)
     |> assign(:visit, %Visit{tasks: []})}
  end

  def handle_event("add-task", _, socket) do
    IO.inspect(socket.assigns.visit_request_changeset, lablel: "changeset")

    existing_tasks =
      Map.get(socket.assigns.visit_request_changeset.changes, :tasks, socket.assigns.visit.tasks)

    tasks =
      existing_tasks
      |> Enum.concat([
        Tasks.change_task(%Task{temp_id: get_temp_id()})
      ])

    visit_request_changeset =
      socket.assigns.visit_request_changeset
      |> Ecto.Changeset.put_assoc(:tasks, tasks)

    {:noreply, assign(socket, :visit_request_changeset, visit_request_changeset)}
  end

  def handle_event("remove-task", %{"remove" => remove_id}, socket) do
    tasks =
      socket.assigns.visit_request_changeset.changes.tasks
      |> Enum.reject(fn %{data: task} ->
        task.temp_id == remove_id
      end)

    visit_request_changeset =
      socket.assigns.visit_request_changeset
      |> Ecto.Changeset.put_assoc(:tasks, tasks)

    {:noreply, assign(socket, visit_request_changeset: visit_request_changeset)}
  end

  @impl true
  def handle_event("request_visit", %{"visit" => visit_params}, socket) do
    IO.inspect(visit_params, label: "visit_params")

    case Visits.create_visit_request(socket.assigns.user.id, visit_params) do
      {:ok, visit} ->
        IO.inspect(visit, lable: "visit created")
        {:noreply, assign(socket, :visit_request_changeset, Visits.change_visit(%Visit{}, %{}))}

      {:error, changeset} ->
        IO.inspect(changeset, label: "changeset")
        {:noreply, assign(socket, :visit_request_changeset, changeset)}
    end
  end

  def handle_event("validate", %{"visit" => visit_params}, socket) do
    changeset = Visits.change_visit(%Visit{}, visit_params)
    {:noreply, assign(socket, :visit_request_changeset, changeset)}
  end

  def handle_event("add-minutes", _, socket) do
    Accounts.add_minutes(socket.assigns.user.id, 300)
    user = Accounts.get_user!(socket.assigns.user.id)
    {:noreply, assign(socket, :minutes, user.minutes)}
  end

  defp get_temp_id, do: :crypto.strong_rand_bytes(5) |> Base.url_encode64() |> binary_part(0, 5)

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-10 h-screen bg-gray-900 text-white">
    <div class="container mx-auto max-w-xl">
    <h1 class="text-3xl font-semibold mb-4">Request a Visit</h1>

    <.form let={f} for={@visit_request_changeset}, phx-change={"validate"} phx_submit= "request_visit">
    <div class="mb-4">
      <%= label f, :date, "Date:", class: "block text-sm font-medium" %>
      <%= date_input f, :date, class: "block bg-gray-900 w-full mt-1 border border-gray-300 rounded-md shadow-sm focus:border-blue-500 focus:ring-blue-500 text-sm" %>
      <%= error_tag f, :date %>
    </div>
    <div class="mb-4">
      <%= label f, :minutes, "Duration (minutes):", class: "block text-sm font-medium" %>
      <%= number_input f, :minutes, min: 1, class: "block bg-gray-900 w-full mt-1 border border-gray-300 rounded-md shadow-sm focus:border-blue-500 focus:ring-blue-500 text-sm" %>
      <%= error_tag f, :minutes %>
    </div>
    <div class="mb-6">
      <%= label f, :special_instructions, "Special Instructions:", class: "block text-sm font-medium" %>
      <%= textarea f, :special_instructions, class: "block bg-gray-900 w-full mt-1 border border-gray-300 rounded-md shadow-sm focus:border-blue-500 focus:ring-blue-500 text-sm" %>
      <%= error_tag f, :special_instructions %>
    </div>
    <%= for t <- inputs_for(f, :tasks) do %>
      <div class="flex flex-wrap -mx-1">
        <div class="form-group px-1 w-3/6">
          <%= label t, :title %>
          <%= text_input t, :title, class: "bg-gray-900 form-control" %>
          <%= error_tag t, :title %>
        </div>

        <div class="form-group px-1 w-2/6">
          <%= label t, :description %>
          <%= text_input t, :description, class: "bg-gray-900 form-control" %>
          <%= error_tag t, :description %>
        </div>

        <div class="form-group px-1 w-1/6">
          <%= label t, :delete %><br>
          <%= if is_nil(t.data.temp_id) do %>
            <%= checkbox t, :delete %>
          <% else %>
            <%= hidden_input t, :temp_id %>
            <a href="#" phx-click="remove-task" phx-value-remove={t.data.temp_id}>&times</a>
          <% end %>
        </div>
      </div>
    <% end %>
    <div>
    <a href="#" phx-click="add-task">Add a task</a>
      <%= submit "Request Visit", class: "w-full px-4 py-2 text-sm font-medium text-white bg-blue-600 rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500" %>
    </div>
    </.form>

    <div class="mt-12">
    <h2 class="text-2xl font-semibold mb-4">Manage Your Minutes</h2>
    <p class="text-lg mb-4">Current available minutes: <%= @minutes %></p>
    <button phx-click="add-minutes" class="w-full px-4 py-2 text-sm font-medium text-white bg-blue-600 rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500">Buy more minutes</button>
    <!-- You can add functionality to add more minutes here -->
    </div>
    </div>
    </div>
    """
  end
end
