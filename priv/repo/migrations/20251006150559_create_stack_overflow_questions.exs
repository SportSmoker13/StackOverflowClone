defmodule StackoverflowClone.Repo.Migrations.CreateStackOverflowQuestions do
  use Ecto.Migration

  def change do
    create table(:stack_overflow_questions) do
      add :question_id, :integer
      add :title, :text
      add :body, :text
      add :tags, {:array, :string}
      add :score, :integer
      add :view_count, :integer
      add :answer_count, :integer
      add :is_answered, :boolean, default: false, null: false
      add :creation_date, :utc_datetime
      add :last_activity_date, :utc_datetime
      add :owner_display_name, :string
      add :owner_reputation, :integer
      add :link, :string
      add :api_response_cached_at, :utc_datetime
      add :search_id, references(:searches, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:stack_overflow_questions, [:question_id, :search_id])
    create index(:stack_overflow_questions, [:search_id])
    create index(:stack_overflow_questions, [:api_response_cached_at])
  end


end
