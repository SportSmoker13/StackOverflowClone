defmodule StackoverflowClone.StackOverflow.Question do
  use Ecto.Schema
  import Ecto.Changeset

  schema "stack_overflow_questions" do
    field :question_id, :integer
    field :title, :string
    field :body, :string
    field :tags, {:array, :string}
    field :score, :integer
    field :view_count, :integer
    field :answer_count, :integer
    field :is_answered, :boolean
    field :creation_date, :utc_datetime
    field :last_activity_date, :utc_datetime
    field :owner_display_name, :string
    field :owner_reputation, :integer
    field :link, :string
    field :api_response_cached_at, :utc_datetime

    belongs_to :search, StackoverflowClone.Searches.Search, foreign_key: :search_id
    has_many :answers, StackoverflowClone.StackOverflow.Answer, foreign_key: :question_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(question, attrs) do
    question
    |> cast(attrs, [
      :search_id,
      :question_id,
      :title,
      :body,
      :tags,
      :score,
      :view_count,
      :answer_count,
      :is_answered,
      :creation_date,
      :last_activity_date,
      :owner_display_name,
      :owner_reputation,
      :link,
      :api_response_cached_at
    ])
    |> validate_required([:question_id, :title, :api_response_cached_at])
    |> foreign_key_constraint(:search_id)
    |> unique_constraint([:question_id, :search_id])
  end
end
