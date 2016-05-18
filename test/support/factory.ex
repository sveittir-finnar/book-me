defmodule Appointments.Factory do
  use ExMachina.Ecto, repo: Appointments.Repo
  alias Appointments.{Repo, Employee, Company}

  def company_factory do
    %Company{name: "A Test Company!"}
  end

  def employee_factory do
    %Employee{
      email: sequence(:email, &"employee-#{&1}@my.email"),
      first_name: "Sveppi",
      last_name: "Grill",
      role: "full",
      password: "krusty"
    }
  end

end
