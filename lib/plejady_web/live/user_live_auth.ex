defmodule PlejadyWeb.UserLiveAuth do
  use PlejadyWeb, :live_view

  alias Plejady.Token

  def on_mount(:default, _params, %{"user_token" => user_token} = _session, socket) do
    socket =
      assign_new(socket, :current_user, fn ->
        Token.get_user_by_session_token(user_token)
      end)
      |> assign(:registry, %{})

    if socket.assigns.current_user do
      {:cont, socket}
    else
      {:halt, redirect(socket, to: "/")}
    end
  end
end
