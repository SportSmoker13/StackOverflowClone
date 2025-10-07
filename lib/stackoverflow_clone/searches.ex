# lib/stackoverflow_clone/search.ex
defmodule StackoverflowClone.Searches do
  @moduledoc """
  The Search context - handles search operations and history.
  """

  import Ecto.Query, warn: false
  alias StackoverflowClone.Repo
  alias StackoverflowClone.Searches.Search

  @doc """
  Creates a new search record.
  """
  def create_search(attrs \\ %{}) do
    %Search{}
    |> Search.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Gets a single search by id.
  """
  def get_search!(id) do
    Repo.get!(Search, id)
  end

  @doc """
  Gets a single search with preloaded associations.
  """
  def get_search_with_questions(id) do
    Search
    |> where([s], s.id == ^id)
    |> preload([s], questions: [:answers])
    |> Repo.one()
  end

  @doc """
  Gets recent searches by session_id or user_fingerprint.
  Returns the 5 most recent searches.
  """
  def get_recent_searches(session_id: session_id) when not is_nil(session_id) do
    Search
    |> where([s], s.session_id == ^session_id)
    |> order_by([s], desc: s.search_timestamp)
    |> limit(5)
    |> Repo.all()
  end

  def get_recent_searches(user_fingerprint: fingerprint) when not is_nil(fingerprint) do
    Search
    |> where([s], s.user_fingerprint == ^fingerprint)
    |> order_by([s], desc: s.search_timestamp)
    |> limit(5)
    |> Repo.all()
  end

  def get_recent_searches(_), do: []

  @doc """
  Checks if a search with the same query already exists for this session.
  Returns the most recent matching search if found.
  """
  def find_cached_search(query_text, session_id) when not is_nil(session_id) do
    # Cache is valid for 1 hour
    cache_threshold = DateTime.add(DateTime.utc_now(), -3600, :second)

    Search
    |> where([s], s.query_text == ^query_text)
    |> where([s], s.session_id == ^session_id)
    |> where([s], s.search_timestamp > ^cache_threshold)
    |> order_by([s], desc: s.search_timestamp)
    |> limit(1)
    |> preload([s], questions: [:answers])
    |> Repo.one()
  end

  def find_cached_search(_query_text, _session_id), do: nil

  @doc """
  Lists all searches.
  """
  def list_searches do
    Repo.all(Search)
  end

  @doc """
  Deletes old searches beyond the 5 most recent per user.
  """
  def cleanup_old_searches(session_id) when not is_nil(session_id) do
    subquery =
      Search
      |> where([s], s.session_id == ^session_id)
      |> order_by([s], desc: s.search_timestamp)
      |> limit(5)
      |> select([s], s.id)

    Search
    |> where([s], s.session_id == ^session_id)
    |> where([s], s.id not in subquery(subquery))
    |> Repo.delete_all()
  end

  def cleanup_old_searches(_), do: {0, nil}
end
