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

# Create some companies

company1 = Repo.insert! %Company{
  name: "Hársnyrtifélagið Gæðahár",
  phone: "+354 823 9745",
  email: "harsnyrtifelagid@gmail.com"
}

company2 = Repo.insert! %Company{
  name: "Tannlæknastofa Héðins",
  phone: "+354 478 1345",
  email: "tannlaeknastofan@gmail.com"
}

IO.inspect(company1)

# Create some users

key = "pu9-VNdgE8V9qZo19rlcg3KUNjpxuixg"

employee1 = %Employee{}
|> Employee.auth_changeset(%{
  email: "test@test.com",
  first_name: "Ari Emil",
  last_name: "Atlason",
  role: "full",
  password: "testing",
  bio: "I specialize in long cuts",
  phone: "+354 823 9745",
  avatar_url: "https://avatars2.githubusercontent.com/u/331083?v=3&s=460",
  company_id: company1.id
}, key)
|> Repo.insert!
|> user_confirmed

employee2 = %Employee{}
|> Employee.auth_changeset(%{
  email: "siggi@test.com",
  first_name: "Sigurður",
  last_name: "Sigurðsson",
  role: "restricted",
  password: "testing",
  bio: "Dreadlocks ftw!",
  phone: "+354 848 4293",
  avatar_url: "https://avatars3.githubusercontent.com/u/2563784?v=3&s=400",
  company_id: company1.id
}, key)
|> Repo.insert!
|> user_confirmed

employee3 = %Employee{}
|> Employee.auth_changeset(%{
  email: "gisli@test.com",
  first_name: "Gísli Marteinn",
  last_name: "Baldursson",
  role: "full",
  password: "testing",
  bio: "I love white teeth",
  phone: "+354 823 9745",
  avatar_url: "https://avatars2.githubusercontent.com/u/331083?v=3&s=460",
  company_id: company2.id
}, key)
|> Repo.insert!
|> user_confirmed
