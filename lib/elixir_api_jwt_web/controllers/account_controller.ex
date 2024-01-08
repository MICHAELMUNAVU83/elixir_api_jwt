defmodule ElixirApiJwtWeb.AccountController do
  use ElixirApiJwtWeb, :controller

  alias ElixirApiJwt.Accounts
  alias ElixirApiJwt.Accounts.Account

  action_fallback ElixirApiJwtWeb.FallbackController

  def index(conn, _params) do
    accounts = Accounts.list_accounts()
    render(conn, "index.json", accounts: accounts)
  end

  def create(conn, %{"account" => account_params}) do
    with {:ok, %Account{} = account} <- Accounts.create_account(account_params),
         {:ok, token, _full_claims} <- ElixirApiJwt.Guardian.encode_and_sign(account) do
      conn
      |> put_status(:created)
      |> render("account_token.json", account: account, token: token)
    end
  end

  def sign_in(conn, %{"account" => %{"email" => email, "hash_password" => hash_password}}) do
    case ElixirApiJwt.Guardian.authenticate(email, hash_password) do
      {:ok, account, token} ->
        conn
        |> put_status(:ok)
        |> render("account_token.json", account: account, token: token)

      {:error, _reason} ->
        conn
        |> put_status(:unauthorized)
        |> render("error.json", error: "invalid credentials")
    end
  end

  def reset_password(conn, %{"account" => account_params}) do
    case Accounts.get_account_by_email(account_params["email"]) do
      nil ->
        conn
        |> put_status(:unauthorized)
        |> render("error.json", error: "Email not found")

      account ->
        case ElixirApiJwt.Guardian.validate_password(
               account_params["current_password"],
               account.hash_password
             ) do
          true ->
            with {:ok, %Account{} = account} <-
                   Accounts.update_account(account, account_params),
                 {:ok, token, _full_claims} <- ElixirApiJwt.Guardian.encode_and_sign(account) do
              render(conn, "account_token.json", account: account, token: token)
            end

          false ->
            conn
            |> put_status(:unauthorized)
            |> render("error.json", error: "invalid credentials")
        end
    end
  end

  def show(conn, %{"id" => id}) do
    account = Accounts.get_account!(id)
    render(conn, "show.json", account: account)
  end

  def update(conn, %{"id" => id, "account" => account_params}) do
    account = Accounts.get_account!(id)

    with {:ok, %Account{} = account} <- Accounts.update_account(account, account_params) do
      render(conn, "show.json", account: account)
    end
  end

  def delete(conn, %{"id" => id}) do
    account = Accounts.get_account!(id)

    with {:ok, %Account{}} <- Accounts.delete_account(account) do
      send_resp(conn, :no_content, "")
    end
  end
end
