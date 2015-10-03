defmodule MithrilBot.LoginController do
  use MithrilBot.Web, :controller

  def login_user(conn, params) do
    if params["data"]["username"] == Application.get_env(:login, :username) &&
       params["data"]["password"] == Application.get_env(:login, :password) do
      case Joken.encode(%{aud: "user"}) do
        {:ok, token} ->
          json conn, %{"token" => token}
        {:error, error} ->
          json conn, %{"error" => error}
      end
    else
      json conn, %{"error" => "incorrect login"}
    end

  end

end
