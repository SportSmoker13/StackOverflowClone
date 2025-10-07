# lib/stackoverflow_clone/llm.ex
defmodule StackoverflowClone.LLM do
  @moduledoc """
  The LLM context - manages LLM rankings for answers.
  """

  import Ecto.Query, warn: false
  alias StackoverflowClone.Repo
  alias StackoverflowClone.LLM.Ranking
  alias StackoverflowClone.StackOverflow.Answer
  alias Ecto.Multi

  @doc """
  Creates LLM rankings for a list of answers in a transaction.
  Returns {:ok, rankings} or {:error, reason}.
  """
  def create_rankings_batch(rankings_attrs_list) do
    Multi.new()
    |> Multi.run(:rankings, fn repo, _changes ->
      rankings =
        rankings_attrs_list
        |> Enum.map(&Ranking.changeset(%Ranking{}, &1))
        |> Enum.reduce_while([], fn changeset, acc ->
          case repo.insert(changeset) do
            {:ok, ranking} -> {:cont, [ranking | acc]}
            {:error, error} -> {:halt, {:error, error}}
          end
        end)

      case rankings do
        {:error, _} = error -> error
        rankings_list -> {:ok, Enum.reverse(rankings_list)}
      end
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{rankings: rankings}} -> {:ok, rankings}
      {:error, _failed_operation, failed_value, _changes} -> {:error, failed_value}
    end
  end

  @doc """
  Gets LLM rankings for a specific search, ordered by LLM rank.
  """
  def get_rankings_by_search(search_id) do
    Ranking
    |> where([r], r.search_id == ^search_id)
    |> order_by([r], asc: r.llm_rank)
    |> preload(:answer)
    |> Repo.all()
  end

  @doc """
  Gets answers with LLM rankings for a search, ordered by LLM rank.
  Returns list of answers in LLM-ranked order.
  """
  def get_llm_ranked_answers(search_id, question_id) do
    from(r in Ranking,
      join: a in Answer,
      on: a.id == r.answer_id,
      where: r.search_id == ^search_id and a.question_id == ^question_id,
      order_by: [asc: r.llm_rank],
      select: %{
        answer: a,
        llm_rank: r.llm_rank,
        llm_confidence_score: r.llm_confidence_score,
        llm_reasoning: r.llm_reasoning,
        llm_model_used: r.llm_model_used
      }
    )
    |> Repo.all()
  end

  @doc """
  Checks if LLM rankings exist for a given search.
  """
  def rankings_exist?(search_id) do
    Ranking
    |> where([r], r.search_id == ^search_id)
    |> Repo.exists?()
  end

  @doc """
  Creates a single ranking.
  """
  def create_ranking(attrs \\ %{}) do
    %Ranking{}
    |> Ranking.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Gets a single ranking.
  """
  def get_ranking!(id), do: Repo.get!(Ranking, id)

  @doc """
  Deletes all rankings for a search (useful for re-ranking).
  """
  def delete_rankings_by_search(search_id) do
    Ranking
    |> where([r], r.search_id == ^search_id)
    |> Repo.delete_all()
  end

  @doc """
  Updates a ranking.
  """
  def update_ranking(%Ranking{} = ranking, attrs) do
    ranking
    |> Ranking.changeset(attrs)
    |> Repo.update()
  end
end
