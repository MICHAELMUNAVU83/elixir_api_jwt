defmodule ElixirApiJwt.Repo do
  use Ecto.Repo,
    otp_app: :elixir_api_jwt,
    adapter: Ecto.Adapters.Postgres
end
