defmodule ElixirApiJwt.Guardian do
  use Guardian, otp_app: :elixir_api_jwt

  def subject_for_token(%{id: id}, _claims) do
    # You can use any value for the subject of your token but
    # it should be useful in retrieving the resource later, see
    # how it being used on `resource_from_claims/1` function.
    # A unique `id` is a good subject, a non-unique email address
    # is a poor subject.
    sub = to_string(id)
    {:ok, sub}
  end

  def subject_for_token(_, _) do
    {:error, :reason_for_error}
  end

  def resource_from_claims(%{"sub" => id}) do
    # Here we'll look up our resource from the claims, the subject can be
    # found in the `"sub"` key. In above `subject_for_token/2` we returned
    # the resource id so here we'll rely on that to look it up.
    case  ElixirApiJwt.Accounts.get_account!(id) do
      nil -> {:error, :reason_for_error}
      resource -> {:ok, resource}
    end
  end

  def resource_from_claims(_claims) do
    {:error, :reason_for_error}
  end

  def authenticate(email, password) do
    case ElixirApiJwt.Accounts.get_account_by_email(email) do
      nil ->
        {:error, :unauthorized}

      resource ->
        case validate_password(password, resource.hash_password) do
          true -> create_token(resource)
          false -> {:error, :reason_for_error}
        end
    end
  end

  def validate_password(password, hash_password) do
    Bcrypt.verify_pass(password, hash_password)
  end

  defp create_token(account) do
    {:ok, token, _full_claims} =
      encode_and_sign(account)

    {:ok, account, token}
  end
end
