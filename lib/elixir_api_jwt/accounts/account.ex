defmodule ElixirApiJwt.Accounts.Account do
  use Ecto.Schema
  import Ecto.Changeset

  schema "accounts" do
    field :email, :string
    field :hash_password, :string

    timestamps()
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [:email, :hash_password])
    |> validate_required([:email, :hash_password])
    |> unique_constraint(:email)
    |> validate_format(:email, ~r/@/)
    |> validate_length(:hash_password, min: 6)
    |> put_password_hash()
  end

  defp put_password_hash(
         %Ecto.Changeset{valid?: true, changes: %{hash_password: hash_password}} = changeset
       ) do
    change(changeset, hash_password: Bcrypt.hash_pwd_salt(hash_password))
  end

  defp put_password_hash(changeset), do: changeset
end
