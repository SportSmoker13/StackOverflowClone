defmodule StackoverflowClone.AnswersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `StackoverflowClone.Answers` context.
  """

  @doc """
  Generate a answer.
  """
  def answer_fixture(attrs \\ %{}) do
    {:ok, answer} =
      attrs
      |> Enum.into(%{
        answer_id: 42,
        body: "some body",
        creation_date: ~U[2025-10-05 15:07:00Z],
        is_accepted: true,
        last_activity_date: ~U[2025-10-05 15:07:00Z],
        original_rank: 42,
        owner_display_name: "some owner_display_name",
        owner_reputation: 42,
        score: 42
      })
      |> StackoverflowClone.Answers.create_answer()

    answer
  end
end
