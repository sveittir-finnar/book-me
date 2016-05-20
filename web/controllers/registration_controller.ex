defmodule Appointments.RegistrationController do
  use Appointments.Web, :controller

  alias Appointments.{Company, Employee, JWT}

  def new(conn, _params) do
    render(conn, "registration.html")
  end

  def create(conn, %{"employee" => employee_params, "company" => company_params}) do
    # HACK: Set this temporarily so the company_id validation will not trigger
    employee_params = Map.merge(employee_params, %{"role" => "full", "company_id" => -1})
    company_changeset = Company.changeset(%Company{}, company_params)
    employee_changeset = Employee.auth_changeset(%Employee{}, employee_params, "banani")

    if company_changeset.valid? && employee_changeset.valid? do
      # TODO(krummi): Use Ecto.Multi when we start using Ecto 2.0
      #               See: https://github.com/elixir-lang/ecto/issues/1114
      case Repo.transaction fn ->
        case Repo.insert(company_changeset) do
          {:ok, company} ->
            employee_changeset = Ecto.Changeset.put_change(employee_changeset, :company_id, company.id)
            case Repo.insert(employee_changeset) do
              {:ok, employee} -> employee
              {:error, changeset} -> Repo.rollback(%{employee: changeset, company: company_changeset})
            end
          {:error, changeset} ->
            Repo.rollback(%{employee: employee_changeset, company: changeset})
        end
      end do
        {:ok, employee} ->
          {:ok, token} = JWT.create_token(conn, employee, :email, :cookie)
          conn
          |> put_status(:created)
          |> put_resp_cookie("access_token", token, [http_only: true])
          |> render(Appointments.ShowView, "show.json", res: "good")
        {:error, changesets} -> registration_err(conn, changesets)
      end
    else
      registration_err(conn, %{employee: employee_changeset, company: company_changeset})
    end
  end

  defp registration_err(conn, changesets) do
    conn
    |> put_status(:unprocessable_entity)
    |> render(Appointments.ChangesetView, "error.json", errors: changesets)
  end
end
