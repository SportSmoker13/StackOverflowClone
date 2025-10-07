defmodule StackoverflowClone.Searches.Search do
  use Ecto.Schema
  import Ecto.Changeset




  schema "searches" do
    field :query_text, :string
    field :session_id, :string
    field :user_fingerprint, :string
    field :search_timestamp, :utc_datetime

    has_many :questions, StackoverflowClone.StackOverflow.Question, foreign_key: :search_id
    has_many :llm_rankings, StackoverflowClone.LLM.Ranking, foreign_key: :search_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(search, attrs) do
    search
    |> cast(attrs, [:query_text, :session_id, :user_fingerprint, :search_timestamp])
    |> validate_required([:query_text])
  end

end
