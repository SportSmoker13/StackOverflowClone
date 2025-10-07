defmodule StackoverflowClone.LLMFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `StackoverflowClone.LLM` context.
  """

  @doc """
  Generate a ranking.
  """
  def ranking_fixture(attrs \\ %{}) do
    {:ok, ranking} =
      attrs
      |> Enum.into(%{
        llm_confidence_score: 120.5,
        llm_model_used: "some llm_model_used",
        llm_rank: 42,
        llm_reasoning: "some llm_reasoning",
        processed_at: ~U[2025-10-05 15:07:00Z]
      })
      |> StackoverflowClone.LLM.create_ranking()

    ranking
  end
end
