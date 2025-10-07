defmodule StackoverflowClone.SearchesTest do
  use StackoverflowClone.DataCase

  alias StackoverflowClone.Searches

  describe "searches" do
    alias StackoverflowClone.Searches.Search

    import StackoverflowClone.SearchesFixtures

    @invalid_attrs %{
      query_text: nil,
      search_timestamp: nil,
      session_id: nil,
      user_fingerprint: nil
    }

    test "list_searches/0 returns all searches" do
      search = search_fixture()
      assert Searches.list_searches() == [search]
    end

    test "get_search!/1 returns the search with given id" do
      search = search_fixture()
      assert Searches.get_search!(search.id) == search
    end

    test "create_search/1 with valid data creates a search" do
      valid_attrs = %{
        query_text: "some query_text",
        search_timestamp: ~U[2025-10-05 15:05:00Z],
        session_id: "some session_id",
        user_fingerprint: "some user_fingerprint"
      }

      assert {:ok, %Search{} = search} = Searches.create_search(valid_attrs)
      assert search.query_text == "some query_text"
      assert search.search_timestamp == ~U[2025-10-05 15:05:00Z]
      assert search.session_id == "some session_id"
      assert search.user_fingerprint == "some user_fingerprint"
    end

    test "create_search/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Searches.create_search(@invalid_attrs)
    end

    test "update_search/2 with valid data updates the search" do
      search = search_fixture()

      update_attrs = %{
        query_text: "some updated query_text",
        search_timestamp: ~U[2025-10-06 15:05:00Z],
        session_id: "some updated session_id",
        user_fingerprint: "some updated user_fingerprint"
      }

      assert {:ok, %Search{} = search} = Searches.update_search(search, update_attrs)
      assert search.query_text == "some updated query_text"
      assert search.search_timestamp == ~U[2025-10-06 15:05:00Z]
      assert search.session_id == "some updated session_id"
      assert search.user_fingerprint == "some updated user_fingerprint"
    end

    test "update_search/2 with invalid data returns error changeset" do
      search = search_fixture()
      assert {:error, %Ecto.Changeset{}} = Searches.update_search(search, @invalid_attrs)
      assert search == Searches.get_search!(search.id)
    end

    test "delete_search/1 deletes the search" do
      search = search_fixture()
      assert {:ok, %Search{}} = Searches.delete_search(search)
      assert_raise Ecto.NoResultsError, fn -> Searches.get_search!(search.id) end
    end

    test "change_search/1 returns a search changeset" do
      search = search_fixture()
      assert %Ecto.Changeset{} = Searches.change_search(search)
    end
  end
end
