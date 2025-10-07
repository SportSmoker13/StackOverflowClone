defmodule StackoverflowClone.Repo.Migrations.CreateSearches do
  use Ecto.Migration

  def change do
    create table(:searches) do
      add :query_text, :text
      add :session_id, :string
      add :user_fingerprint, :string
      add :search_timestamp, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create index(:searches, [:query_text])
    create index(:searches, [:session_id, :search_timestamp])
    create index(:searches, [:user_fingerprint, :search_timestamp])
    create index(:searches, [:search_timestamp])
  end
end
