defmodule Appointments.ClientController do
  use Appointments.Web, :controller

  import Appointments.Authorize
  alias Appointments.Client

  def action(conn, _), do: authorize_action conn, __MODULE__

  plug :scrub_params, "client" when action in [:create, :update]

  def index(conn, _params, user) do
    query = from c in Client, where: c.company_id == ^user.company_id, select: c
    clients = Repo.all(query)
    render(conn, "index.html", clients: clients)
  end

  def new(conn, _params, _user) do
    changeset = Client.changeset(%Client{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"client" => client_params}, user) do
    client_params = Map.put(client_params, "company_id", user.company_id)
    changeset = Client.changeset(%Client{}, client_params)

    case Repo.insert(changeset) do
      {:ok, _client} ->
        conn
        |> put_flash(:info, "Client created successfully.")
        |> redirect(to: client_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}, user) do
    client = get_by_id_and_company(Client, id, user)
    render(conn, "show.html", client: client)
  end

  def edit(conn, %{"id" => id}, user) do
    client = get_by_id_and_company(Client, id, user)
    changeset = Client.changeset(client)
    render(conn, "edit.html", client: client, changeset: changeset)
  end

  def update(conn, %{"id" => id, "client" => client_params}, user) do
    client = get_by_id_and_company(Client, id, user)
    changeset = Client.changeset(client, client_params)

    case Repo.update(changeset) do
      {:ok, client} ->
        conn
        |> put_flash(:info, "Client updated successfully.")
        |> redirect(to: client_path(conn, :show, client))
      {:error, changeset} ->
        render(conn, "edit.html", client: client, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, user) do
    client = get_by_id_and_company(Client, id, user)
    Repo.delete!(client)

    conn
    |> put_flash(:info, "Client deleted successfully.")
    |> redirect(to: client_path(conn, :index))
  end
end
