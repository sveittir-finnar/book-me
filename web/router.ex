defmodule Appointments.Router do
  use Appointments.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Openmaize.Authenticate
  end

  scope "/", Appointments do
    pipe_through :browser

    get "/", PageController, :indexs

    # authentication
    get "/registration", PageController, :registration
    get "/confirm", PageController, :confirm
    get "/reset", PageController, :askreset
    post "/reset", PageController, :askreset_password
    get "/resetting", PageController, :reset
    post "/resetting", PageController, :reset_password
    get "/login", PageController, :login, as: :login
    post "/login", PageController, :login_user, as: :login
    get "/logout", PageController, :logout, as: :logout

    resources "/companies", CompanyController
    resources "/employees", EmployeeController
  end

end
