# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Appointments.Repo.insert!(%Appointments.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Appointments.Company
alias Appointments.Employee
alias Appointments.Repo
import Openmaize.DB

# Create a company
company_params = %Company{
  name: "Hársnyrtifélagið Gæðahár",
  phone: "+354 823 9745",
  email: "harsnyrtifelagid@gmail.com"
}
company = Repo.insert! company_params
IO.inspect(company)

# Create an user
employee_params = %{
  email: "test@test.com",
  name: "Ari Emil Atlason",
  role: "full",
  password: "testing",
  bio: "I specialize in long cuts",
  phone: "+354 823 9745",
  avatar_url: "https://avatars2.githubusercontent.com/u/331083?v=3&s=460",
  company_id: company.id
}

employee = %Employee{}
|> Employee.auth_changeset(employee_params, "pu9-VNdgE8V9qZo19rlcg3KUNjpxuixg")
|> Repo.insert!
|> user_confirmed
