defmodule StackoverflowClone.StackOverflowTest do
  use StackoverflowClone.DataCase

  alias StackoverflowClone.StackOverflow

  describe "stack_overflow_questions" do
    alias StackoverflowClone.StackOverflow.Question

    import StackoverflowClone.StackOverflowFixtures

    @invalid_attrs %{
      answer_count: nil,
      api_response_cached_at: nil,
      body: nil,
      creation_date: nil,
      is_answered: nil,
      last_activity_date: nil,
      link: nil,
      owner_display_name: nil,
      owner_reputation: nil,
      question_id: nil,
      score: nil,
      tags: nil,
      title: nil,
      view_count: nil
    }

    test "list_stack_overflow_questions/0 returns all stack_overflow_questions" do
      question = question_fixture()
      assert StackOverflow.list_stack_overflow_questions() == [question]
    end

    test "get_question!/1 returns the question with given id" do
      question = question_fixture()
      assert StackOverflow.get_question!(question.id) == question
    end

    test "create_question/1 with valid data creates a question" do
      valid_attrs = %{
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
      }

      assert {:ok, %Question{} = question} = StackOverflow.create_question(valid_attrs)
      assert question.answer_count == 42
      assert question.api_response_cached_at == ~U[2025-10-05 15:05:00Z]
      assert question.body == "some body"
      assert question.creation_date == ~U[2025-10-05 15:05:00Z]
      assert question.is_answered == true
      assert question.last_activity_date == ~U[2025-10-05 15:05:00Z]
      assert question.link == "some link"
      assert question.owner_display_name == "some owner_display_name"
      assert question.owner_reputation == 42
      assert question.question_id == 42
      assert question.score == 42
      assert question.tags == ["option1", "option2"]
      assert question.title == "some title"
      assert question.view_count == 42
    end

    test "create_question/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = StackOverflow.create_question(@invalid_attrs)
    end

    test "update_question/2 with valid data updates the question" do
      question = question_fixture()

      update_attrs = %{
        answer_count: 43,
        api_response_cached_at: ~U[2025-10-06 15:05:00Z],
        body: "some updated body",
        creation_date: ~U[2025-10-06 15:05:00Z],
        is_answered: false,
        last_activity_date: ~U[2025-10-06 15:05:00Z],
        link: "some updated link",
        owner_display_name: "some updated owner_display_name",
        owner_reputation: 43,
        question_id: 43,
        score: 43,
        tags: ["option1"],
        title: "some updated title",
        view_count: 43
      }

      assert {:ok, %Question{} = question} = StackOverflow.update_question(question, update_attrs)
      assert question.answer_count == 43
      assert question.api_response_cached_at == ~U[2025-10-06 15:05:00Z]
      assert question.body == "some updated body"
      assert question.creation_date == ~U[2025-10-06 15:05:00Z]
      assert question.is_answered == false
      assert question.last_activity_date == ~U[2025-10-06 15:05:00Z]
      assert question.link == "some updated link"
      assert question.owner_display_name == "some updated owner_display_name"
      assert question.owner_reputation == 43
      assert question.question_id == 43
      assert question.score == 43
      assert question.tags == ["option1"]
      assert question.title == "some updated title"
      assert question.view_count == 43
    end

    test "update_question/2 with invalid data returns error changeset" do
      question = question_fixture()
      assert {:error, %Ecto.Changeset{}} = StackOverflow.update_question(question, @invalid_attrs)
      assert question == StackOverflow.get_question!(question.id)
    end

    test "delete_question/1 deletes the question" do
      question = question_fixture()
      assert {:ok, %Question{}} = StackOverflow.delete_question(question)
      assert_raise Ecto.NoResultsError, fn -> StackOverflow.get_question!(question.id) end
    end

    test "change_question/1 returns a question changeset" do
      question = question_fixture()
      assert %Ecto.Changeset{} = StackOverflow.change_question(question)
    end
  end
end
