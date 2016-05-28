defmodule Appointments.ServiceController do
  use Appointments.Web, :controller

  import Appointments.Authorize
  alias Appointments.Service

  def action(conn, _), do: authorize_action conn, __MODULE__

  plug :scrub_params, "service" when action in [:create, :update]

  def index(conn, _params, user) do
    query = from s in Service,
            where: s.company_id == ^user.company_id,
            select: s
    services = Repo.all(query)
    render(conn, "index.html", services: services)
  end

  def new(conn, _params, _user) do
    changeset = Service.changeset(%Service{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"service" => service_params}, user) do
    service_params = Map.put(service_params, "company_id", user.company_id)
    changeset = Service.changeset(%Service{}, service_params)

    case Repo.insert(changeset) do
      {:ok, _service} ->
        conn
        |> put_flash(:info, "Service created successfully.")
        |> redirect(to: service_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}, user) do
    service = get_by_id_and_company(Service, id, user)
    render(conn, "show.html", service: service)
  end

  def edit(conn, %{"id" => id}, user) do
    service = get_by_id_and_company(Service, id, user)
    changeset = Service.changeset(service)
    render(conn, "edit.html", service: service, changeset: changeset)
  end

  def update(conn, %{"id" => id, "service" => service_params}, user) do
    service = get_by_id_and_company(Service, id, user)
    changeset = Service.changeset(service, service_params)

    case Repo.update(changeset) do
      {:ok, service} ->
        conn
        |> put_flash(:info, "Service updated successfully.")
        |> redirect(to: service_path(conn, :show, service))
      {:error, changeset} ->
        render(conn, "edit.html", service: service, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, user) do
    service = get_by_id_and_company(Service, id, user)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(service)

    conn
    |> put_flash(:info, "Service deleted successfully.")
    |> redirect(to: service_path(conn, :index))
  end
end
