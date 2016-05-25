defmodule Appointments.RegistrationController do
  use Appointments.Web, :controller

  alias Appointments.{Company, Employee, JWT}

  def new(conn, _params) do
    render(conn, "registration.html")
  end

  def create(conn, %{"employee" => empl_params, "company" => comp_params}) do
    # HACK: Set this temporarily so the company_id validation will not trigger
    empl_params = Map.merge(
      empl_params, %{"role" => "full", "company_id" => Ecto.UUID.generate()})
    comp_changeset = Company.changeset(%Company{}, comp_params)

    key = :crypto.strong_rand_bytes(24) |> Base.url_encode64
    empl_changeset = Employee.auth_changeset(%Employee{}, empl_params, key)

    if comp_changeset.valid? && empl_changeset.valid? do
      # TODO(krummi): Use Ecto.Multi when we start using Ecto 2.0
      #               See: https://github.com/elixir-lang/ecto/issues/1114
      case Repo.transaction fn ->
        case Repo.insert(comp_changeset) do
          {:ok, company} ->
            empl_changeset = Ecto.Changeset.put_change(
              empl_changeset, :company_id, company.id)
            case Repo.insert(empl_changeset) do
              {:ok, employee} -> employee
              {:error, changeset} -> Repo.rollback(
                %{employee: changeset, company: comp_changeset})
            end
          {:error, changeset} ->
            Repo.rollback(%{employee: empl_changeset, company: changeset})
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
      registration_err(conn, %{employee: empl_changeset, company: comp_changeset})
    end
  end

  defp registration_err(conn, changesets) do
    conn
    |> put_status(:unprocessable_entity)
    |> render(Appointments.ChangesetView, "error.json", errors: changesets)
  end
end
