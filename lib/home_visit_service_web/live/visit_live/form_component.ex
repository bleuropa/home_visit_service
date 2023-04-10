defmodule HomeVisitServiceWeb.VisitLive.FormComponent do
  use HomeVisitServiceWeb, :live_component

  alias HomeVisitService.Visits

  @impl true
  def update(%{visit: visit} = assigns, socket) do
    changeset = Visits.change_visit(visit)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"visit" => visit_params}, socket) do
    changeset =
      socket.assigns.visit
      |> Visits.change_visit(visit_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"visit" => visit_params}, socket) do
    save_visit(socket, socket.assigns.action, visit_params)
  end

  defp save_visit(socket, :edit, visit_params) do
    case Visits.update_visit(socket.assigns.visit, visit_params) do
      {:ok, _visit} ->
        {:noreply,
         socket
         |> put_flash(:info, "Visit updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_visit(socket, :new, visit_params) do
    case Visits.create_visit(visit_params) do
      {:ok, _visit} ->
        {:noreply,
         socket
         |> put_flash(:info, "Visit created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
