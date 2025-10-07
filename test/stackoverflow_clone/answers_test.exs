defmodule StackoverflowClone.AnswersTest do
  use StackoverflowClone.DataCase

  alias StackoverflowClone.Answers

  describe "answers" do
    alias StackoverflowClone.Answers.Answer

    import StackoverflowClone.AnswersFixtures

    @invalid_attrs %{
      answer_id: nil,
      body: nil,
      creation_date: nil,
      is_accepted: nil,
      last_activity_date: nil,
      original_rank: nil,
      owner_display_name: nil,
      owner_reputation: nil,
      score: nil
    }

    test "list_answers/0 returns all answers" do
      answer = answer_fixture()
      assert Answers.list_answers() == [answer]
    end

    test "get_answer!/1 returns the answer with given id" do
      answer = answer_fixture()
      assert Answers.get_answer!(answer.id) == answer
    end

    test "create_answer/1 with valid data creates a answer" do
      valid_attrs = %{
        answer_id: 42,
        body: "some body",
        creation_date: ~U[2025-10-05 15:07:00Z],
        is_accepted: true,
        last_activity_date: ~U[2025-10-05 15:07:00Z],
        original_rank: 42,
        owner_display_name: "some owner_display_name",
        owner_reputation: 42,
        score: 42
      }

      assert {:ok, %Answer{} = answer} = Answers.create_answer(valid_attrs)
      assert answer.answer_id == 42
      assert answer.body == "some body"
      assert answer.creation_date == ~U[2025-10-05 15:07:00Z]
      assert answer.is_accepted == true
      assert answer.last_activity_date == ~U[2025-10-05 15:07:00Z]
      assert answer.original_rank == 42
      assert answer.owner_display_name == "some owner_display_name"
      assert answer.owner_reputation == 42
      assert answer.score == 42
    end

    test "create_answer/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Answers.create_answer(@invalid_attrs)
    end

    test "update_answer/2 with valid data updates the answer" do
      answer = answer_fixture()

      update_attrs = %{
        answer_id: 43,
        body: "some updated body",
        creation_date: ~U[2025-10-06 15:07:00Z],
        is_accepted: false,
        last_activity_date: ~U[2025-10-06 15:07:00Z],
        original_rank: 43,
        owner_display_name: "some updated owner_display_name",
        owner_reputation: 43,
        score: 43
      }

      assert {:ok, %Answer{} = answer} = Answers.update_answer(answer, update_attrs)
      assert answer.answer_id == 43
      assert answer.body == "some updated body"
      assert answer.creation_date == ~U[2025-10-06 15:07:00Z]
      assert answer.is_accepted == false
      assert answer.last_activity_date == ~U[2025-10-06 15:07:00Z]
      assert answer.original_rank == 43
      assert answer.owner_display_name == "some updated owner_display_name"
      assert answer.owner_reputation == 43
      assert answer.score == 43
    end

    test "update_answer/2 with invalid data returns error changeset" do
      answer = answer_fixture()
      assert {:error, %Ecto.Changeset{}} = Answers.update_answer(answer, @invalid_attrs)
      assert answer == Answers.get_answer!(answer.id)
    end

    test "delete_answer/1 deletes the answer" do
      answer = answer_fixture()
      assert {:ok, %Answer{}} = Answers.delete_answer(answer)
      assert_raise Ecto.NoResultsError, fn -> Answers.get_answer!(answer.id) end
    end

    test "change_answer/1 returns a answer changeset" do
      answer = answer_fixture()
      assert %Ecto.Changeset{} = Answers.change_answer(answer)
    end
  end
end
