# lib/stackoverflow_clone/clients/llm_client.ex (Updated)
defmodule StackoverflowClone.Clients.LLMClient do
  @moduledoc """
  Client for interacting with LLM services with retry logic.
  """

  require Logger

  @max_retries 3
  @retry_delay 2000

  def rank_answers(question, answers, retry_count \\ 0) do
    model = get_model()
    prompt = build_ranking_prompt(question, answers)

    case call_llm(model, prompt) do
      {:ok, llm_response} ->
        parse_ranking_response(llm_response, answers, model)

      {:error, {:request_failed, :econnrefused}} when retry_count < @max_retries ->
        Logger.warning("LLM connection refused, retrying in #{@retry_delay}ms (attempt #{retry_count + 1}/#{@max_retries})")
        Process.sleep(@retry_delay)
        rank_answers(question, answers, retry_count + 1)

      error ->
        error
    end
  end

  defp get_model do
    Application.get_env(:stackoverflow_clone, :llm_model, "llama2")
  end

  defp get_base_url do
    Application.get_env(:stackoverflow_clone, :llm_base_url, "http://localhost:11434")
  end

  defp call_llm(model, prompt) do
    base_url = get_base_url()
    url = "#{base_url}/v1/chat/completions"

    # First check if Ollama is reachable
    case check_ollama_health(base_url) do
      :ok ->
        make_llm_request(url, model, prompt)

      {:error, reason} ->
        Logger.error("Ollama health check failed: #{inspect(reason)}")
        {:error, {:health_check_failed, reason}}
    end
  end

  defp check_ollama_health(base_url) do
    health_url = "#{base_url}/api/tags"

    case HTTPoison.get(health_url, [], timeout: 5_000, recv_timeout: 5_000) do
      {:ok, %HTTPoison.Response{status_code: 200}} ->
        :ok

      {:ok, %HTTPoison.Response{status_code: code}} ->
        {:error, {:unexpected_status, code}}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  defp make_llm_request(url, model, prompt) do
    headers = [
      {"Content-Type", "application/json"},
      {"Accept", "application/json"}
    ]

    headers =
      case Application.get_env(:stackoverflow_clone, :openai_api_key) do
        nil -> headers
        key -> [{"Authorization", "Bearer #{key}"} | headers]
      end

    body = %{
      model: model,
      messages: [
        %{
          role: "system",
          content: "You are a helpful assistant that analyzes Stack Overflow answers and returns structured JSON responses."
        },
        %{
          role: "user",
          content: prompt
        }
      ],
      temperature: 0.3,
      max_tokens: 1000,
      stream: false
    }

    Logger.info("Calling LLM API: #{url} with model: #{model}")

    case HTTPoison.post(url, Jason.encode!(body), headers, timeout: 120_000, recv_timeout: 120_000) do
      {:ok, %HTTPoison.Response{status_code: 200, body: response_body}} ->
        case Jason.decode(response_body) do
          {:ok, decoded} ->
            content = get_in(decoded, ["choices", Access.at(0), "message", "content"])
            {:ok, %{content: content, model: model}}

          {:error, reason} ->
            Logger.error("Failed to decode LLM response: #{inspect(reason)}")
            {:error, :invalid_json}
        end

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        Logger.error("LLM API Error: #{status_code} - #{body}")
        {:error, {:http_error, status_code}}

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error("LLM Request failed: #{inspect(reason)}")
        {:error, {:request_failed, reason}}
    end
  end

  # ... rest of the functions remain the same
  defp build_ranking_prompt(question, answers) do
    question_text = strip_html(question.title)

    answers_text =
      answers
      |> Enum.with_index(1)
      |> Enum.map(fn {answer, idx} ->
        """
        Answer #{idx}:
        Score: #{answer.score}
        Accepted: #{answer.is_accepted}
        Content: #{strip_html(answer.body) |> String.slice(0, 500)}
        ---
        """
      end)
      |> Enum.join("\n")

    """
    You are an expert programmer analyzing Stack Overflow answers for relevance and accuracy.

    Question: #{question_text}

    Here are the answers to rank:
    #{answers_text}

    Your task:
    1. Rank these answers from most to least relevant/accurate (1 being best)
    2. Consider: correctness, completeness, clarity, and code quality
    3. Respond ONLY with a JSON array in this exact format:
    [
      {"answer_number": 1, "rank": 1, "confidence": 0.95, "reasoning": "Clear and accurate solution"},
      {"answer_number": 2, "rank": 2, "confidence": 0.85, "reasoning": "Good but incomplete"}
    ]

    Respond with ONLY the JSON array, no other text.
    """
  end

  defp parse_ranking_response(llm_response, answers, model) do
    content = llm_response.content

    json_content =
      content
      |> String.replace(~r/```\n?/, "")
      |> String.trim()

    case Jason.decode(json_content) do
      {:ok, rankings} when is_list(rankings) ->
        ranked_results =
          rankings
          |> Enum.map(fn ranking ->
            answer_idx = ranking["answer_number"] - 1
            answer = Enum.at(answers, answer_idx)

            if answer do
              %{
                answer_id: answer.id,
                rank: ranking["rank"],
                confidence_score: ranking["confidence"],
                reasoning: ranking["reasoning"],
                model_used: model
              }
            else
              nil
            end
          end)
          |> Enum.reject(&is_nil/1)

        {:ok, ranked_results}

      {:ok, _} ->
        Logger.error("LLM response is not a valid array")
        fallback_ranking(answers, model)

      {:error, reason} ->
        Logger.error("Failed to parse LLM ranking JSON: #{inspect(reason)}")
        fallback_ranking(answers, model)
    end
  end

  defp fallback_ranking(answers, model) do
    Logger.warning("Using fallback ranking based on Stack Overflow scores")

    ranked_results =
      answers
      |> Enum.sort_by(& &1.score, :desc)
      |> Enum.with_index(1)
      |> Enum.map(fn {answer, rank} ->
        %{
          answer_id: answer.id,
          rank: rank,
          confidence_score: 0.5,
          reasoning: "Fallback ranking by SO score (LLM parsing failed)",
          model_used: "#{model}_fallback"
        }
      end)

    {:ok, ranked_results}
  end

  defp strip_html(nil), do: ""

  defp strip_html(html_text) do
    html_text
    |> HtmlSanitizeEx.strip_tags()
    |> String.replace(~r/\s+/, " ")
    |> String.trim()
  end
end
