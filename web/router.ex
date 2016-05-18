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

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Appointments do
    pipe_through :browser

    get "/", PageController, :index

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

    resources "/employees", EmployeeController
    resources "/companies", CompanyController
  end

  scope "/", Appointments do
    pipe_through :api

    post "/registration", PageController, :registration_post
  end

end
