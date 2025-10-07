# lib/stackoverflow_clone/search_orchestrator.ex
defmodule StackoverflowClone.SearchOrchestrator do
  @moduledoc """
  Orchestrates the complete search flow:
  1. Check cache
  2. Fetch from Stack Overflow API
  3. Store results
  4. Trigger LLM ranking (async)
  """

  alias StackoverflowClone.Searches.Search
  alias StackoverflowClone.{Searches, StackOverflow, Cache}
  alias StackoverflowClone.Clients.{StackOverflowClient, LLMClient}

  require Logger

  @doc """
  Performs a complete search operation.
  Returns {:ok, search} or {:error, reason}.
  """
  def perform_search(query_text, session_id, user_fingerprint) do
    # 1. Check if we have a recent cached search
    case Searches.find_cached_search(query_text, session_id) |> IO.inspect() do
      %Search{} = cached_search ->
        Logger.info("Using cached search for: #{query_text}")
        {:ok, cached_search}

      nil ->
        # 2. Create new search record
        with {:ok, search} <- create_search_record(query_text, session_id, user_fingerprint),
             # 3. Fetch from Stack Overflow API
             {:ok, so_response} <- fetch_from_stackoverflow(query_text),
             # 4. Store questions and answers
             {:ok, questions} <- store_questions_and_answers(search.id, so_response),
             # 5. Trigger LLM ranking asynchronously
             :ok <- trigger_llm_ranking(search.id, questions) do
          # 6. Cleanup old searches
          Searches.cleanup_old_searches(session_id)

          # 7. Return search with loaded associations
          {:ok, Searches.get_search_with_questions(search.id)}
        else
          {:error, reason} = error ->
            Logger.error("Search failed: #{inspect(reason)}")
            error
        end
    end
  end

  defp create_search_record(query_text, session_id, user_fingerprint) do
    Searches.create_search(%{
      query_text: query_text,
      session_id: session_id,
      user_fingerprint: user_fingerprint
    })
  end

  defp fetch_from_stackoverflow(query_text) do
    cache_key = Cache.generate_cache_key(query_text)

    # Check API cache
    if Cache.cache_valid?(cache_key, "so_api") do
      Logger.info("Stack Overflow API cache valid")
    end

    case StackOverflowClient.search_questions(query_text) do
      {:ok, response} ->
        # Update cache metadata
        Cache.create_metadata(%{
          cache_key: cache_key,
          cache_type: "so_api",
          last_fetched_at: DateTime.utc_now(),
          expires_at: DateTime.add(DateTime.utc_now(), 3600, :second),
          api_quota_remaining: response["quota_remaining"],
          metadata: %{"has_more" => response["has_more"]}
        })
        |> IO.inspect()

        {:ok, response}

      error ->
        error
    end
  end

  defp store_questions_and_answers(search_id, so_response) do
    questions = so_response["items"] || []

    # Take first question with answers
    case Enum.find(questions, fn q -> q["answer_count"] > 0 end) do
      nil ->
        {:error, :no_answered_questions}

      question ->
        question_attrs = parse_question(question, search_id)
        answers_attrs = parse_answers(question["answers"] || [])

        case StackOverflow.create_question_with_answers(question_attrs, answers_attrs) do
          {:ok, %{question: question, answers: _answers}} ->
            {:ok, [question]}

          error ->
            error
        end
    end
  end

  defp parse_question(so_question, search_id) do
    %{
      search_id: search_id,
      question_id: so_question["question_id"],
      title: so_question["title"],
      body: so_question["body"],
      tags: so_question["tags"] || [],
      score: so_question["score"] || 0,
      view_count: so_question["view_count"] || 0,
      answer_count: so_question["answer_count"] || 0,
      is_answered: so_question["is_answered"] || false,
      creation_date: parse_timestamp(so_question["creation_date"]),
      last_activity_date: parse_timestamp(so_question["last_activity_date"]),
      owner_display_name: get_in(so_question, ["owner", "display_name"]),
      owner_reputation: get_in(so_question, ["owner", "reputation"]),
      link: so_question["link"],
      api_response_cached_at: DateTime.utc_now()
    }
  end

  defp parse_answers(so_answers) do
    Enum.map(so_answers, fn answer ->
      %{
        answer_id: answer["answer_id"],
        body: answer["body"],
        score: answer["score"] || 0,
        is_accepted: answer["is_accepted"] || false,
        creation_date: parse_timestamp(answer["creation_date"]),
        last_activity_date: parse_timestamp(answer["last_activity_date"]),
        owner_display_name: get_in(answer, ["owner", "display_name"]),
        owner_reputation: get_in(answer, ["owner", "reputation"])
      }
    end)
  end

  defp parse_timestamp(nil), do: nil

  defp parse_timestamp(unix_timestamp) when is_integer(unix_timestamp) do
    DateTime.from_unix!(unix_timestamp)
  end

  defp trigger_llm_ranking(search_id, questions) do
    # Trigger async task for LLM ranking
    Task.start(fn ->
      perform_llm_ranking(search_id, questions)
    end)

    :ok
  end

  defp perform_llm_ranking(search_id, questions) do
    Enum.each(questions, fn question ->
      answers = StackOverflow.list_answers_for_question(question.id)

      if length(answers) > 0 do
        case LLMClient.rank_answers(question, answers) do
          {:ok, ranked_results} ->
            store_llm_rankings(search_id, ranked_results)

          {:error, reason} ->
            Logger.error("LLM ranking failed: #{inspect(reason)}")
        end
      end
    end)
  end

  defp store_llm_rankings(search_id, ranked_results) do
    rankings_attrs =
      Enum.map(ranked_results, fn result ->
        %{
          search_id: search_id,
          answer_id: result.answer_id,
          llm_rank: result.rank,
          llm_confidence_score: result.confidence_score,
          llm_reasoning: result.reasoning,
          llm_model_used: result.model_used,
          processed_at: DateTime.utc_now()
        }
      end)

    StackoverflowClone.LLM.create_rankings_batch(rankings_attrs)
  end
end
