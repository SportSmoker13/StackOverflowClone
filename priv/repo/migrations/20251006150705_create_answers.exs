defmodule StackoverflowClone.Repo.Migrations.CreateAnswers do
  use Ecto.Migration

  def change do
    create table(:answers) do
      add :answer_id, :integer
      add :body, :text
      add :score, :integer
      add :is_accepted, :boolean, default: false, null: false
      add :creation_date, :utc_datetime
      add :last_activity_date, :utc_datetime
      add :owner_display_name, :string
      add :owner_reputation, :integer
      add :original_rank, :integer
      add :question_id, references(:stack_overflow_questions, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:answers, [:question_id])
    create unique_index(:answers, [:answer_id, :question_id])
    create index(:answers, [:question_id, :original_rank])
    create index(:answers, [:question_id, :is_accepted, :score])
  end
end
