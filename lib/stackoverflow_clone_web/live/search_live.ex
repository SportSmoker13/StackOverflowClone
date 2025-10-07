# lib/stackoverflow_clone_web/live/search_live.ex
defmodule StackoverflowCloneWeb.SearchLive do
  use StackoverflowCloneWeb, :live_view

  alias StackoverflowClone.SearchOrchestrator
  alias StackoverflowClone.{Searches, StackOverflow, LLM}

  require Logger

  @impl true
  def mount(_params, _session, socket) do
    session_id = generate_session_id(socket)

    user_fingerprint =
      case get_connect_params(socket) do
        %{"fingerprint" => fp} -> fp
        _ -> nil
      end

    {:ok,
     socket
     |> assign(:session_id, session_id)
     |> assign(:user_fingerprint, user_fingerprint)
     |> assign(:query, "")
     |> assign(:search, nil)
     |> assign(:questions, [])
     |> assign(:selected_question, nil)
     |> assign(:answers, [])
     |> assign(:llm_ranked_answers, [])
     |> assign(:active_tab, "original")
     |> assign(:loading, false)
     |> assign(:llm_loading, false)
     |> assign(:error, nil)
     |> assign(:recent_searches, [])
     |> load_recent_searches()}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    search_id = params["search_id"]

    socket =
      if search_id do
        load_search_by_id(socket, search_id)
      else
        socket
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event("update_query", %{"query" => query}, socket) do
    {:noreply, assign(socket, :query, query)}
  end

  @impl true
  def handle_event("search", %{"query" => query}, socket) do
    if String.trim(query) == "" do
      {:noreply, put_flash(socket, :error, "Please enter a search query")}
    else
      socket =
        socket
        |> assign(:loading, true)
        |> assign(:error, nil)

      # Perform async search
      send(self(), {:perform_search, query})

      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("select_question", %{"question-id" => question_id}, socket) do
    {:noreply, select_question(socket, question_id)}
  end

  @impl true
  def handle_event("switch_tab", %{"tab" => tab}, socket) do
    {:noreply, assign(socket, :active_tab, tab)}
  end

  @impl true
  def handle_event("select_recent_search", %{"search-id" => search_id}, socket) do
    socket = load_search_by_id(socket, search_id)
    {:noreply, push_patch(socket, to: ~p"/search?search_id=#{search_id}")}
  end

  @impl true
  def handle_event("trigger_llm_ranking", _params, socket) do
    if socket.assigns.selected_question && socket.assigns.search do
      socket = assign(socket, :llm_loading, true)

      Task.start(fn ->
        perform_llm_ranking(
          self(),
          socket.assigns.search.id,
          socket.assigns.selected_question
        )
      end)

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:perform_search, query}, socket) do
    session_id = socket.assigns.session_id
    user_fingerprint = socket.assigns.user_fingerprint

    case SearchOrchestrator.perform_search(query, session_id, user_fingerprint) do
      {:ok, search} ->
        socket =
          socket
          |> assign(:loading, false)
          |> assign(:search, search)
          |> assign(:questions, search.questions)
          |> load_recent_searches()
          |> maybe_select_first_question()
          |> put_flash(:info, "Search completed successfully")

        {:noreply, socket}

      {:error, reason} ->
        Logger.error("Search failed: #{inspect(reason)}")

        socket =
          socket
          |> assign(:loading, false)
          |> assign(:error, format_error(reason))
          |> put_flash(:error, "Search failed: #{format_error(reason)}")

        {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:llm_ranking_complete, ranked_answers}, socket) do
    {:noreply,
     socket
     |> assign(:llm_ranked_answers, ranked_answers)
     |> assign(:llm_loading, false)
     |> assign(:active_tab, "llm_ranked")
     |> put_flash(:info, "LLM ranking completed")}
  end

  @impl true
  def handle_info({:llm_ranking_failed, reason}, socket) do
    Logger.error("LLM ranking failed: #{inspect(reason)}")

    {:noreply,
     socket
     |> assign(:llm_loading, false)
     |> put_flash(:error, "LLM ranking failed: #{format_error(reason)}")}
  end

  # Private Functions

  defp generate_session_id(socket) do
    case get_connect_params(socket) do
      %{"session_id" => session_id} when not is_nil(session_id) ->
        session_id

      _ ->
        "session_" <> (:crypto.strong_rand_bytes(16) |> Base.encode16(case: :lower))
    end
  end

  defp load_recent_searches(socket) do
    recent =
      Searches.get_recent_searches(session_id: socket.assigns.session_id)
      |> Enum.take(5)

    assign(socket, :recent_searches, recent)
  end

  defp load_search_by_id(socket, search_id) do
    case Searches.get_search_with_questions(search_id) do
      nil ->
        socket
        |> put_flash(:error, "Search not found")
        |> assign(:search, nil)

      search ->
        socket
        |> assign(:search, search)
        |> assign(:query, search.query_text)
        |> assign(:questions, search.questions)
        |> maybe_select_first_question()
        |> load_llm_rankings_if_exist()
    end
  end

  defp maybe_select_first_question(socket) do
    case socket.assigns.questions do
      [first_question | _] ->
        select_question(socket, first_question.id)

      [] ->
        socket
    end
  end

  defp select_question(socket, question_id) do
    question = Enum.find(socket.assigns.questions, &(&1.id == question_id))

    if question do
      answers = StackOverflow.list_answers_for_question(question.id)

      socket
      |> assign(:selected_question, question)
      |> assign(:answers, answers)
      |> load_llm_rankings_if_exist()
    else
      socket
    end
  end

  defp load_llm_rankings_if_exist(socket) do
    if socket.assigns.search && socket.assigns.selected_question do
      search_id = socket.assigns.search.id
      question_id = socket.assigns.selected_question.id

      ranked_answers = LLM.get_llm_ranked_answers(search_id, question_id)

      if length(ranked_answers) > 0 do
        assign(socket, :llm_ranked_answers, ranked_answers)
      else
        socket
      end
    else
      socket
    end
  end

  defp perform_llm_ranking(parent_pid, search_id, question) do
    answers = StackOverflow.list_answers_for_question(question.id)

    case StackoverflowClone.Clients.LLMClient.rank_answers(question, answers) do
      {:ok, ranked_results} ->
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

        case LLM.create_rankings_batch(rankings_attrs) do
          {:ok, _rankings} ->
            # Reload the ranked answers
            ranked_answers = LLM.get_llm_ranked_answers(search_id, question.id)
            send(parent_pid, {:llm_ranking_complete, ranked_answers})

          {:error, reason} ->
            send(parent_pid, {:llm_ranking_failed, reason})
        end

      {:error, reason} ->
        send(parent_pid, {:llm_ranking_failed, reason})
    end
  end

  defp format_error(:no_answered_questions), do: "No questions with answers found"
  defp format_error({:http_error, code, _}), do: "HTTP Error #{code}"
  defp format_error({:request_failed, reason}), do: "Request failed: #{inspect(reason)}"
  defp format_error(reason), do: inspect(reason)

  # Template - see next section for the HEEX template
end
