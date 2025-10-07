# lib/stackoverflow_clone/cache.ex
defmodule StackoverflowClone.Cache do
  @moduledoc """
  The Cache context - manages cache metadata and invalidation.
  """

  import Ecto.Query, warn: false
  alias StackoverflowClone.Repo
  alias StackoverflowClone.Cache.Metadata

  @doc """
  Creates cache metadata entry.
  """
  def create_metadata(attrs \\ %{}) do
    %Metadata{}
    |> Metadata.changeset(attrs)
    |> Repo.insert(
      on_conflict: {:replace_all_except, [:id, :inserted_at]},
      conflict_target: [:cache_key, :cache_type]
    )
  end

  @doc """
  Gets cache metadata by key and type.
  """
  def get_metadata(cache_key, cache_type) do
    Metadata
    |> where([m], m.cache_key == ^cache_key and m.cache_type == ^cache_type)
    |> Repo.one()
  end

  @doc """
  Checks if cache is valid (not expired).
  """
  def cache_valid?(cache_key, cache_type) do
    now = DateTime.utc_now()

    Metadata
    |> where([m], m.cache_key == ^cache_key and m.cache_type == ^cache_type)
    |> where([m], is_nil(m.expires_at) or m.expires_at > ^now)
    |> Repo.exists?()
  end

  @doc """
  Updates cache metadata.
  """
  def update_metadata(%Metadata{} = metadata, attrs) do
    metadata
    |> Metadata.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes expired cache entries.
  """
  def cleanup_expired_cache do
    now = DateTime.utc_now()

    Metadata
    |> where([m], not is_nil(m.expires_at) and m.expires_at < ^now)
    |> Repo.delete_all()
  end

  @doc """
  Gets remaining API quota from cache metadata.
  """
  def get_api_quota(cache_type) do
    Metadata
    |> where([m], m.cache_type == ^cache_type)
    |> order_by([m], desc: m.last_fetched_at)
    |> limit(1)
    |> select([m], m.api_quota_remaining)
    |> Repo.one()
  end

  @doc """
  Lists all cache metadata entries.
  """
  def list_metadata do
    Repo.all(Metadata)
  end

  @doc """
  Deletes cache metadata.
  """
  def delete_metadata(%Metadata{} = metadata) do
    Repo.delete(metadata)
  end

  @doc """
  Generates cache key from query text using hash.
  """
  def generate_cache_key(query_text) do
    :crypto.hash(:sha256, query_text)
    |> Base.encode16(case: :lower)
  end
end
