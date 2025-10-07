defmodule StackoverflowClone.SearchesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `StackoverflowClone.Searches` context.
  """

  @doc """
  Generate a search.
  """
  def search_fixture(attrs \\ %{}) do
    {:ok, search} =
      attrs
      |> Enum.into(%{
        query_text: "some query_text",
        search_timestamp: ~U[2025-10-05 15:05:00Z],
        session_id: "some session_id",
        user_fingerprint: "some user_fingerprint"
      })
      |> StackoverflowClone.Searches.create_search()

    search
  end
end
