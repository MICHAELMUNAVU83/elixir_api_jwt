defmodule ElixirApiJwt.GuardianPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :elixir_api_jwt,
    module: ElixirApiJwt.Guardian,
    error_handler: ElixirApiJwt.GuardianErrorHandler

  plug Guardian.Plug.VerifyHeader
  plug Guardian.Plug.VerifySession
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
