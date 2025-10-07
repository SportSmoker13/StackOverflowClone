defmodule StackoverflowClone.Cache.Metadata do
  use Ecto.Schema
  import Ecto.Changeset




  schema "cache_metadata" do
    field :cache_key, :string
    field :cache_type, :string
    field :last_fetched_at, :utc_datetime
    field :expires_at, :utc_datetime
    field :api_quota_remaining, :integer
    field :metadata, :map

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(metadata, attrs) do
    metadata
    |> cast(attrs, [
      :cache_key, :cache_type, :last_fetched_at, :expires_at,
      :api_quota_remaining, :metadata
    ])
    |> validate_required([:cache_key, :cache_type, :last_fetched_at])
    |> unique_constraint([:cache_key, :cache_type])
  end
end
