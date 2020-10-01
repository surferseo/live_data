defmodule PhoenixLivedataTodomvc.Repo do
  use Ecto.Repo,
    otp_app: :phoenix_livedata_todomvc,
    adapter: Ecto.Adapters.Postgres
end
