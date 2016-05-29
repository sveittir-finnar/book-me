defmodule Appointments.ReservationController do
  use Appointments.Web, :controller

  import Appointments.Authorize
  alias Appointments.Reservation

  plug :scrub_params, "reservation" when action in [:create, :update]

  def action(conn, _), do: authorize_action conn, __MODULE__

  def index(conn, _params, user) do
    query = from r in Reservation,
            where: r.company_id == ^user.company_id,
            select: r
    reservations = Repo.all(query)
    render(conn, "index.json", reservations: reservations)
  end

  def create(conn, %{"reservation" => reservation_params}, user) do
    changeset = Reservation.changeset(%Reservation{}, reservation_params)

    case Repo.insert(changeset) do
      {:ok, reservation} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", reservation_path(conn, :show, reservation))
        |> render("show.json", reservation: reservation)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Appointments.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}, user) do
    reservation = get_by_id_and_company(Reservation, id, user)
    render(conn, "show.json", reservation: reservation)
  end

  def update(conn, %{"id" => id, "reservation" => reservation_params}, user) do
    reservation = get_by_id_and_company(Reservation, id, user)
    changeset = Reservation.changeset(reservation, reservation_params)

    case Repo.update(changeset) do
      {:ok, reservation} ->
        render(conn, "show.json", reservation: reservation)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Appointments.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, user) do
    reservation = get_by_id_and_company(Reservation, id, user)
    Repo.delete!(reservation)
    send_resp(conn, :no_content, "")
  end
end
