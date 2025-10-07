defmodule StackoverflowClone.StackOverflowFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `StackoverflowClone.StackOverflow` context.
  """

  @doc """
  Generate a question.
  """
  def question_fixture(attrs \\ %{}) do
    {:ok, question} =
      attrs
      |> Enum.into(%{
        answer_count: 42,
        api_response_cached_at: ~U[2025-10-05 15:05:00Z],
        body: "some body",
        creation_date: ~U[2025-10-05 15:05:00Z],
        is_answered: true,
        last_activity_date: ~U[2025-10-05 15:05:00Z],
        link: "some link",
        owner_display_name: "some owner_display_name",
        owner_reputation: 42,
        question_id: 42,
        score: 42,
        tags: ["option1", "option2"],
        title: "some title",
        view_count: 42
      })
      |> StackoverflowClone.StackOverflow.create_question()

    question
  end
end
