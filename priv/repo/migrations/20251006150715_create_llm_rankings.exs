defmodule StackoverflowClone.Repo.Migrations.CreateLlmRankings do
  use Ecto.Migration

  def change do
    create table(:llm_rankings) do
      add :llm_rank, :integer
      add :llm_confidence_score, :float
      add :llm_reasoning, :text
      add :llm_model_used, :string
      add :processed_at, :utc_datetime
      add :search_id, references(:searches, on_delete: :nothing)
      add :answer_id, references(:answers, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:llm_rankings, [:search_id])
    create index(:llm_rankings, [:answer_id])
    create unique_index(:llm_rankings, [:search_id, :answer_id])
    create index(:llm_rankings, [:search_id, :llm_rank])
  end


end
