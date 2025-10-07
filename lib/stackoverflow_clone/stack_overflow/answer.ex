defmodule StackoverflowClone.StackOverflow.Answer do
  use Ecto.Schema
  import Ecto.Changeset

  schema "answers" do
    field :answer_id, :integer
    field :body, :string
    field :score, :integer
    field :is_accepted, :boolean
    field :creation_date, :utc_datetime
    field :last_activity_date, :utc_datetime
    field :owner_display_name, :string
    field :owner_reputation, :integer
    field :original_rank, :integer

    belongs_to :question, StackoverflowClone.StackOverflow.Question, foreign_key: :question_id
    has_many :llm_rankings, StackoverflowClone.LLM.Ranking, foreign_key: :answer_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(answer, attrs) do
    answer
    |> cast(attrs, [
      :question_id,
      :answer_id,
      :body,
      :score,
      :is_accepted,
      :creation_date,
      :last_activity_date,
      :owner_display_name,
      :owner_reputation,
      :original_rank
    ])
    |> validate_required([:answer_id, :body, :original_rank])
    |> foreign_key_constraint(:question_id)
    |> unique_constraint([:answer_id, :question_id])
  end
end
