defmodule Appointments.Factory do
  use ExMachina.Ecto, repo: Appointments.Repo
  alias Appointments.{Employee, Company, Service, Client}

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

  def service_factory do
    %Service{
      name: "Haircut",
      duration: 45,
      company: build(:company)
    }
  end

  def client_factory do
    %Client{
      first_name: "Gisli",
      last_name: "Baldursson",
      company: build(:company)
    }
  end
end
