defmodule Appointments.CompanyController do
  use Appointments.Web, :controller

  alias Appointments.Company
  import Appointments.Authorize

  plug :scrub_params, "company" when action in [:update]

  # TODO(krummi): Revisit this when I know something
  def action(conn, _) do
    case action_name(conn) do
      :show -> show(conn, conn.params)
      _ -> authorize_action(conn, __MODULE__)
    end
  end

  def show(conn, %{"id" => id}) do
    company = Repo.get!(Company, id)
    render(conn, "show.html", company: company)
  end

  def edit(conn, _params, user) do
    company = Repo.get!(Company, user.company_id)
    changeset = Company.changeset(company)
    render(conn, "edit.html", company: company,
      changeset: changeset, countries: get_country_list())
  end

  def update(conn, %{"company" => company_params}, user) do
    company = Repo.get!(Company, user.company_id)
    changeset = Company.changeset(company, company_params)

    case Repo.update(changeset) do
      {:ok, company} ->
        conn
        |> put_flash(:info, "Company updated successfully.")
        |> redirect(to: company_path(conn, :show, company))
      {:error, changeset} ->
        render(conn, "edit.html", company: company, changeset: changeset,
          countries: get_country_list())
    end
  end

  defp get_country_list() do
    Enum.map(Countries.all, &({to_string(&1.name), to_string(&1.alpha2)}))
    |> Enum.sort(&(elem(&1, 0) < elem(&2, 0)))
  end
end
