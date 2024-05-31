defmodule Clays.Repo do
  use Ecto.Repo,
    otp_app: :clays,
    adapter: Ecto.Adapters.Postgres
end
