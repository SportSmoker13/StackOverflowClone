defmodule StackoverflowClone.Clients.StackOverflowClient do
  @moduledoc """
  Client for interacting with Stack Exchange API.
  Documentation: https://api.stackexchange.com/docs
  """

  require Logger

  @base_url "https://api.stackexchange.com/2.3"
  @site "stackoverflow"

  # Custom filter to include question body, answers, and answer bodies
  # Created at: https://api.stackexchange.com/docs/create-filter
  # Includes: question.answers;answer.body;question.body;question.owner;answer.owner
  @custom_filter "!nNPvSNdWme"

  @doc """
  Searches for questions on Stack Overflow based on query text.
  Returns questions with their answers included.
  """
  def search_questions(query_text, opts \\ []) do
    page_size = Keyword.get(opts, :page_size, 5)
    order = Keyword.get(opts, :order, "desc")
    sort = Keyword.get(opts, :sort, "relevance")
    max_results = Keyword.get(opts, :max_results, 3)

    params = %{
      order: order,
      sort: sort,
      # Changed from 'intitle' to 'q' for broader search
      q: query_text,
      site: @site,
      pagesize: page_size,
      filter: @custom_filter,
      # Tagged questions tend to have better answers
      tagged: Keyword.get(opts, :tagged, nil)
    }

    url = "#{@base_url}/search/advanced"

    case make_request(:get, url, params) do
      {:ok, response} ->
        # Fetch answers for questions with answers
        questions_with_answers =
          response["items"]
          |> Enum.filter(fn q -> q["answer_count"] > 0 end)
          # Now configurable, defaults to 3
          |> Enum.take(max_results)
          |> Enum.map(&fetch_answers_for_question/1)
          |> Enum.filter(&(&1 != nil))

        {:ok, Map.put(response, "items", questions_with_answers)}

      error ->
        error
    end
  end

  @doc """
  Fetches a specific question by ID with its answers.
  """
  def get_question(question_id) do
    url = "#{@base_url}/questions/#{question_id}"

    params = %{
      site: @site,
      filter: @custom_filter
    }

    case make_request(:get, url, params) do
      {:ok, response} ->
        case response["items"] do
          [question | _] ->
            question_with_answers = fetch_answers_for_question(question)
            {:ok, question_with_answers}

          [] ->
            {:error, :not_found}
        end

      error ->
        error
    end
  end

  @doc """
  Fetches answers for a specific question.
  """
  def get_answers(question_id, opts \\ []) do
    page_size = Keyword.get(opts, :page_size, 10)
    order = Keyword.get(opts, :order, "desc")
    sort = Keyword.get(opts, :sort, "votes")

    url = "#{@base_url}/questions/#{question_id}/answers"

    params = %{
      site: @site,
      pagesize: page_size,
      order: order,
      sort: sort,
      filter: "withbody"
    }

    make_request(:get, url, params)
  end

  # Private Functions

  defp fetch_answers_for_question(question) do
    question_id = question["question_id"]

    case get_answers(question_id, page_size: 10) do
      {:ok, answers_response} ->
        Map.put(question, "answers", answers_response["items"])

      {:error, reason} ->
        Logger.warning("Failed to fetch answers for question #{question_id}: #{inspect(reason)}")
        Map.put(question, "answers", [])
    end
  end

  defp make_request(method, url, params) do
    headers = [
      {"Accept", "application/json"},
      {"Accept-Encoding", "gzip"}
    ]

    query_string = URI.encode_query(params |> Enum.reject(fn {_k, v} -> is_nil(v) end))
    full_url = "#{url}?#{query_string}"

    Logger.info("Stack Overflow API Request: #{method} #{full_url}")

    case HTTPoison.request(method, full_url, "", headers, timeout: 30_000, recv_timeout: 30_000) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case :zlib.gunzip(body) |> Jason.decode() do
          {:ok, decoded} ->
            log_quota(decoded)
            {:ok, decoded}

          {:error, reason} ->
            Logger.error("Failed to decode JSON: #{inspect(reason)}")
            {:error, :invalid_json}
        end

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        Logger.error("Stack Overflow API Error: #{status_code} - #{body}")
        {:error, {:http_error, status_code, body}}

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error("HTTP Request failed: #{inspect(reason)}")
        {:error, {:request_failed, reason}}
    end
  end

  defp log_quota(response) do
    quota_remaining = response["quota_remaining"]
    quota_max = response["quota_max"]

    if quota_remaining && quota_max do
      Logger.info("Stack Overflow API Quota: #{quota_remaining}/#{quota_max} remaining")
    end
  end
end
