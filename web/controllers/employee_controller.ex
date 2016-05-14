defmodule Appointments.EmployeeController do
  use Appointments.Web, :controller

  import Appointments.Authorize
  alias Appointments.Employee

  import Ecto.Query, only: [from: 2]

  plug :scrub_params, "employee" when action in [:create, :update]

  def action(conn, _), do: authorize_action conn, __MODULE__

  def index(conn, _params, user) do
    query = from e in Employee,
            where: e.company_id == ^user.company_id,
            select: e
    employees = Repo.all query
    render(conn, "index.html", employees: employees)
  end

  def new(conn, _params, _user) do
    changeset = Employee.changeset(%Employee{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"employee" => employee_params}, _user) do
    changeset = Employee.changeset(%Employee{}, employee_params)

    case Repo.insert(changeset) do
      {:ok, _employee} ->
        conn
        |> put_flash(:info, "Employee created successfully.")
        |> redirect(to: employee_path(conn, :index))
      {:error, changeset} ->
        IO.inspect(changeset)
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}, _user) do
    employee = Repo.get!(Employee, id)
    render(conn, "show.html", employee: employee)
  end

  def edit(conn, %{"id" => id}, _user) do
    employee = Repo.get!(Employee, id)
    changeset = Employee.changeset(employee)
    render(conn, "edit.html", employee: employee, changeset: changeset)
  end

  def update(conn, %{"id" => id, "employee" => employee_params}, _user) do
    employee = Repo.get!(Employee, id)
    changeset = Employee.changeset(employee, employee_params)

    case Repo.update(changeset) do
      {:ok, employee} ->
        conn
        |> put_flash(:info, "Employee updated successfully.")
        |> redirect(to: employee_path(conn, :show, employee))
      {:error, changeset} ->
        render(conn, "edit.html", employee: employee, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, _user) do
    employee = Repo.get!(Employee, id)
    Repo.delete!(employee)

    conn
    |> put_flash(:info, "Employee deleted successfully.")
    |> redirect(to: employee_path(conn, :index))
  end
end
