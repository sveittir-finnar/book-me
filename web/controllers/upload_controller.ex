defmodule Appointments.UploadController do
  use Appointments.Web, :controller

  import Appointments.Authorize
  alias Appointments.Avatar

  def action(conn, _), do: authorize_action conn, __MODULE__

  def create(conn, %{"image" => image}, user) do
    # Handle failure by causing no-match error
    {:ok, file} = Avatar.store({image, user})
    json(conn, %{path: Avatar.url({file, user})})
  end
end
