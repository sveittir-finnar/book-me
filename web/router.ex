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

    # Authentication & registration
    get "/registration", RegistrationController, :new
    get "/confirm", PageController, :confirm
    get "/reset", PageController, :askreset
    post "/reset", PageController, :askreset_password
    get "/resetting", PageController, :reset
    post "/resetting", PageController, :reset_password
    get "/login", PageController, :login, as: :login
    post "/login", PageController, :login_user, as: :login
    get "/logout", PageController, :logout, as: :logout

    # Settings
    get "/settings", CompanyController, :edit
    patch "/settings", CompanyController, :update

    # Uploads
    post "/uploads", UploadController, :create

    # Resources
    resources "/employees", EmployeeController
    resources "/companies", CompanyController, only: [:show]
    resources "/services", ServiceController
    resources "/clients", ClientController
  end

  scope "/", Appointments do
    pipe_through :api

    post "/registration", RegistrationController, :create
  end

end
