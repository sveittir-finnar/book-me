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

alias Appointments.{Repo, Company, Employee, Service, Client, Reservation}
import Openmaize.DB
use Timex

# Clean everything up (in the correct order)

Repo.delete_all(Reservation)
Repo.delete_all(Client)
Repo.delete_all(Service)
Repo.delete_all(Employee)
Repo.delete_all(Company)

# Create companies

company1 = Repo.insert!(%Company{
  name: "Hársnyrtifélagið Gæðahár",
  phone: "+354 823 9745",
  email: "harsnyrtifelagid@gmail.com",
  description: "Hársnyrtifélagið is one of Reykjavíks hidden gems when it comes to hair.",
  website_url: "https://news.ycombinator.com/",
  facebook: "harsnyrtifelagid",
  twitter: "@harsnyrtifelagid",
  location_name: "Kramhúsið",
  location_street: "Skólavörðustígur 19",
  location_city: "Reykjavík",
  location_zip: "101",
  location_country: "IS",
  opening_hours: %{
    mon: [[9, 17]],
    tue: [[9, 17]],
    wed: [[9, 17]],
    tue: [[9, 17]],
    fri: [[9, 12], [13, 17]],
    sat: [[13, 16]]
  }
})

company2 = Repo.insert!(%Company{
  name: "Tannlæknastofa Héðins",
  phone: "+354 478 1345",
  email: "tannlaeknastofan@gmail.com"
})

IO.inspect(company1)

# Create users

key = "a"

employee1 = Employee.auth_changeset(%Employee{}, %{
  email: "test@test.com",
  first_name: "Ari Emil",
  last_name: "Atlason",
  role: "full",
  password: "testing",
  bio: "I specialize in long cuts",
  phone: "+354 823 9745",
  avatar_url: "https://avatars2.githubusercontent.com/u/331083?v=3&s=460",
  company_id: company1.id
}, key) |> Repo.insert!

employee2 = Employee.auth_changeset(%Employee{}, %{
  email: "siggi@test.com",
  first_name: "Sigurður",
  last_name: "Sigurðsson",
  role: "restricted",
  password: "testing",
  bio: "Dreadlocks ftw!",
  phone: "+354 848 4293",
  avatar_url: "https://avatars3.githubusercontent.com/u/2563784?v=3&s=400",
  company_id: company1.id
}, key) |> Repo.insert!

user_confirmed(employee1)
user_confirmed(employee2)

Employee.auth_changeset(%Employee{}, %{
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

# Create services

service1 = Service.changeset(%Service{}, %{
  name: "Haircut: Crew cut",
  description: "Look ridiculously cool; get a crew cut!",
  duration: 30,
  cleanup_duration: 0,
  pricing: "4500 kr.",
  company_id: company1.id
}) |> Repo.insert!

Service.changeset(%Service{}, %{
  name: "Haircut: Mohawk cut",
  description: "Mohawk haircuts are the shit this summer!",
  duration: 45,
  cleanup_duration: 15,
  company_id: company1.id
}) |> Repo.insert!


Service.changeset(%Service{}, %{
  name: "Dentist appointment",
  description: "A classic mouth wash!",
  duration: 60,
  company_id: company2.id
}) |> Repo.insert!

# Create clients

client1 = Client.changeset(%Client{}, %{
  first_name: "Gisli Marteinn",
  last_name: "Baldursson",
  email: "gmb@gmb.is",
  phone: "+354 123 4567",
  notes: "A good fella.",
  company_id: company1.id
}) |> Repo.insert!

Client.changeset(%Client{}, %{
  first_name: "Sigurgeir",
  last_name: "Baldursson",
  email: "siggi@baldursson.is",
  company_id: company1.id
}) |> Repo.insert!

Client.changeset(%Client{}, %{
  first_name: "Kjartan",
  last_name: "Marteinsson",
  company_id: company2.id
}) |> Repo.insert!

# Create personal reservations

Reservation.personal_changeset(%Reservation{}, %{
  company_id: company1.id,
  type: "personal",
  start_time: Date.to_datetime(Timex.shift(DateTime.today(), days: 2, hours: 9)),
  title: "Hvítasunnudagurinn",
  all_day: true,
  employee_id: employee1.id
}) |> Repo.insert!

Reservation.client_changeset(%Reservation{}, %{
  company_id: company1.id,
  type: "client",
  start_time: Date.to_datetime(Timex.shift(DateTime.today(), days: 1, hours: 10)),
  duration: 45,
  cleanup_duration: 5,
  client_id: client1.id,
  service_id: service1.id
}) |> Repo.insert!

Reservation.client_changeset(%Reservation{}, %{
  company_id: company1.id,
  type: "client",
  start_time: Date.to_datetime(Timex.shift(DateTime.today(), days: 1, hours: 11)),
  duration: 30,
  client_id: client1.id,
  service_id: service1.id
}) |> Repo.insert!
