defmodule MithrilBot.LoginController do
  use MithrilBot.Web, :controller

  def login_user(conn, params) do
    if params["data"]["username"] == Application.get_env(:login, :username) &&
       params["data"]["password"] == Application.get_env(:login, :password) do
      my_token = %{user_id: 1}
        |> Joken.token
        |> Joken.with_signer(Joken.hs256("my_secret"))
        |> Joken.sign
        |> Joken.get_compact
      json conn, %{"token" => my_token}
    else
      json conn, %{"error" => "incorrect login"}
    end

  end

end
