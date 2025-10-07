defmodule StackoverflowClone.CacheFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `StackoverflowClone.Cache` context.
  """

  @doc """
  Generate a metadata.
  """
  def metadata_fixture(attrs \\ %{}) do
    {:ok, metadata} =
      attrs
      |> Enum.into(%{
        api_quota_remaining: 42,
        cache_key: "some cache_key",
        cache_type: "some cache_type",
        expires_at: ~U[2025-10-05 15:07:00Z],
        last_fetched_at: ~U[2025-10-05 15:07:00Z],
        metadata: %{}
      })
      |> StackoverflowClone.Cache.create_metadata()

    metadata
  end
end
