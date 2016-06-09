defmodule Appointments.ReservationView do
  use Appointments.Web, :view

  alias Appointments.Reservation

  def render("index.json", %{reservations: reservations}) do
    %{data: render_many(reservations, Appointments.ReservationView, "reservation.json")}
  end

  def render("show.json", %{reservation: reservation}) do
    %{data: render_one(reservation, Appointments.ReservationView, "reservation.json")}
  end

  def render("reservation.json", %{reservation: reservation}) do
    %{
      id: reservation.id,
      title: reservation.title,
      type: reservation.type,
      all_day: reservation.all_day,
      start_time: reservation.start_time,
      end_time: reservation.end_time,
      duration: reservation.duration,
      cleanup_duration: reservation.cleanup_duration,
      notes: reservation.notes,
      employee_id: reservation.employee_id,
      service_id: reservation.service_id,
      company_id: reservation.company_id,
      client_id: reservation.client_id,
      computed: %{
        end_time: Reservation.get_computed_end_time(reservation)
      }
    }
  end
end
