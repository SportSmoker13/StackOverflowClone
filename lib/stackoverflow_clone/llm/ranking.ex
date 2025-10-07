defmodule StackoverflowClone.LLM.Ranking do
  use Ecto.Schema
  import Ecto.Changeset

  schema "llm_rankings" do
    field :llm_rank, :integer
    field :llm_confidence_score, :float
    field :llm_reasoning, :string
    field :llm_model_used, :string
    field :processed_at, :utc_datetime

    belongs_to :search, StackoverflowClone.Searches.Search, foreign_key: :search_id
    belongs_to :answer, StackoverflowClone.StackOverflow.Answer, foreign_key: :answer_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(ranking, attrs) do
    ranking
    |> cast(attrs, [
      :search_id,
      :answer_id,
      :llm_rank,
      :llm_confidence_score,
      :llm_reasoning,
      :llm_model_used,
      :processed_at
    ])
    |> validate_required([:llm_rank, :llm_model_used, :processed_at])
    |> foreign_key_constraint(:search_id)
    |> foreign_key_constraint(:answer_id)
    |> unique_constraint([:search_id, :answer_id])
  end
end
