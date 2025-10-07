defmodule StackoverflowClone.LLMTest do
  use StackoverflowClone.DataCase

  alias StackoverflowClone.LLM

  describe "llm_rankings" do
    alias StackoverflowClone.LLM.Ranking

    import StackoverflowClone.LLMFixtures

    @invalid_attrs %{
      llm_confidence_score: nil,
      llm_model_used: nil,
      llm_rank: nil,
      llm_reasoning: nil,
      processed_at: nil
    }

    test "list_llm_rankings/0 returns all llm_rankings" do
      ranking = ranking_fixture()
      assert LLM.list_llm_rankings() == [ranking]
    end

    test "get_ranking!/1 returns the ranking with given id" do
      ranking = ranking_fixture()
      assert LLM.get_ranking!(ranking.id) == ranking
    end

    test "create_ranking/1 with valid data creates a ranking" do
      valid_attrs = %{
        llm_confidence_score: 120.5,
        llm_model_used: "some llm_model_used",
        llm_rank: 42,
        llm_reasoning: "some llm_reasoning",
        processed_at: ~U[2025-10-05 15:07:00Z]
      }

      assert {:ok, %Ranking{} = ranking} = LLM.create_ranking(valid_attrs)
      assert ranking.llm_confidence_score == 120.5
      assert ranking.llm_model_used == "some llm_model_used"
      assert ranking.llm_rank == 42
      assert ranking.llm_reasoning == "some llm_reasoning"
      assert ranking.processed_at == ~U[2025-10-05 15:07:00Z]
    end

    test "create_ranking/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = LLM.create_ranking(@invalid_attrs)
    end

    test "update_ranking/2 with valid data updates the ranking" do
      ranking = ranking_fixture()

      update_attrs = %{
        llm_confidence_score: 456.7,
        llm_model_used: "some updated llm_model_used",
        llm_rank: 43,
        llm_reasoning: "some updated llm_reasoning",
        processed_at: ~U[2025-10-06 15:07:00Z]
      }

      assert {:ok, %Ranking{} = ranking} = LLM.update_ranking(ranking, update_attrs)
      assert ranking.llm_confidence_score == 456.7
      assert ranking.llm_model_used == "some updated llm_model_used"
      assert ranking.llm_rank == 43
      assert ranking.llm_reasoning == "some updated llm_reasoning"
      assert ranking.processed_at == ~U[2025-10-06 15:07:00Z]
    end

    test "update_ranking/2 with invalid data returns error changeset" do
      ranking = ranking_fixture()
      assert {:error, %Ecto.Changeset{}} = LLM.update_ranking(ranking, @invalid_attrs)
      assert ranking == LLM.get_ranking!(ranking.id)
    end

    test "delete_ranking/1 deletes the ranking" do
      ranking = ranking_fixture()
      assert {:ok, %Ranking{}} = LLM.delete_ranking(ranking)
      assert_raise Ecto.NoResultsError, fn -> LLM.get_ranking!(ranking.id) end
    end

    test "change_ranking/1 returns a ranking changeset" do
      ranking = ranking_fixture()
      assert %Ecto.Changeset{} = LLM.change_ranking(ranking)
    end
  end
end
