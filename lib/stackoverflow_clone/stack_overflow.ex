# lib/stackoverflow_clone/stack_overflow.ex
defmodule StackoverflowClone.StackOverflow do
  @moduledoc """
  The StackOverflow context - manages questions and answers from Stack Overflow API.
  """

  import Ecto.Query, warn: false
  alias StackoverflowClone.Repo
  alias StackoverflowClone.StackOverflow.{Question, Answer}
  alias Ecto.Multi

  @doc """
  Creates a question with its answers in a transaction.
  """
  def create_question_with_answers(question_attrs, answers_attrs) do
    Multi.new()
    |> Multi.insert(:question, Question.changeset(%Question{}, question_attrs))
    |> Multi.run(:answers, fn repo, %{question: question} ->
      answers =
        answers_attrs
        |> Enum.with_index(1)
        |> Enum.map(fn {answer_attrs, index} ->
          answer_attrs
          |> Map.put(:question_id, question.id)
          |> Map.put(:original_rank, index)
        end)
        |> Enum.map(&Answer.changeset(%Answer{}, &1))
        |> Enum.map(&repo.insert!/1)

      {:ok, answers}
    end)
    |> Repo.transaction()
  end

  @doc """
  Gets a question by id with preloaded answers.
  """
  def get_question_with_answers(id) do
    Question
    |> where([q], q.id == ^id)
    |> preload([q], answers: ^from(a in Answer, order_by: [asc: a.original_rank]))
    |> Repo.one()
  end

  @doc """
  Gets questions by search_id with preloaded answers.
  """
  def get_questions_by_search(search_id) do
    Question
    |> where([q], q.search_id == ^search_id)
    |> preload([q], answers: ^from(a in Answer, order_by: [asc: a.original_rank]))
    |> Repo.all()
  end

  @doc """
  Gets a question by Stack Overflow question_id.
  """
  def get_question_by_so_id(question_id) do
    Question
    |> where([q], q.question_id == ^question_id)
    |> preload([q], answers: ^from(a in Answer, order_by: [asc: a.original_rank]))
    |> Repo.one()
  end

  @doc """
  Creates a single question.
  """
  def create_question(attrs \\ %{}) do
    %Question{}
    |> Question.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a single answer.
  """
  def create_answer(attrs \\ %{}) do
    %Answer{}
    |> Answer.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Lists all answers for a question.
  """
  def list_answers_for_question(question_id) do
    Answer
    |> where([a], a.question_id == ^question_id)
    |> order_by([a], asc: a.original_rank)
    |> Repo.all()
  end

  @doc """
  Gets answers with LLM rankings preloaded.
  """
  def get_answers_with_llm_rankings(question_id, search_id) do
    from(a in Answer,
      where: a.question_id == ^question_id,
      left_join: lr in assoc(a, :llm_rankings),
      where: lr.search_id == ^search_id or is_nil(lr.id),
      order_by: [asc: a.original_rank],
      preload: [llm_rankings: lr]
    )
    |> Repo.all()
  end

  @doc """
  Gets a single answer.
  """
  def get_answer!(id), do: Repo.get!(Answer, id)

  @doc """
  Updates a question.
  """
  def update_question(%Question{} = question, attrs) do
    question
    |> Question.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a question and all associated answers.
  """
  def delete_question(%Question{} = question) do
    Repo.delete(question)
  end
end
