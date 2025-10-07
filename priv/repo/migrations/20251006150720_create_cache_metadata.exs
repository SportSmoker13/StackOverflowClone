defmodule StackoverflowClone.Repo.Migrations.CreateCacheMetadata do
  use Ecto.Migration

  def change do
    create table(:cache_metadata) do
      add :cache_key, :string
      add :cache_type, :string
      add :last_fetched_at, :utc_datetime
      add :expires_at, :utc_datetime
      add :api_quota_remaining, :integer
      add :metadata, :map

      timestamps(type: :utc_datetime)
    end

    create unique_index(:cache_metadata, [:cache_key, :cache_type])
    create index(:cache_metadata, [:expires_at])
  end
end
