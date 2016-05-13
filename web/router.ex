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
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index

    # authentication
    get "/", PageController, :index
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

  # Other scopes may use custom stacks.
  # scope "/api", Appointments do
  #   pipe_through :api
  # end
end
