defmodule StackoverflowClone.CacheTest do
  use StackoverflowClone.DataCase

  alias StackoverflowClone.Cache

  describe "cache_metadata" do
    alias StackoverflowClone.Cache.Metadata

    import StackoverflowClone.CacheFixtures

    @invalid_attrs %{
      api_quota_remaining: nil,
      cache_key: nil,
      cache_type: nil,
      expires_at: nil,
      last_fetched_at: nil,
      metadata: nil
    }

    test "list_cache_metadata/0 returns all cache_metadata" do
      metadata = metadata_fixture()
      assert Cache.list_cache_metadata() == [metadata]
    end

    test "get_metadata!/1 returns the metadata with given id" do
      metadata = metadata_fixture()
      assert Cache.get_metadata!(metadata.id) == metadata
    end

    test "create_metadata/1 with valid data creates a metadata" do
      valid_attrs = %{
        api_quota_remaining: 42,
        cache_key: "some cache_key",
        cache_type: "some cache_type",
        expires_at: ~U[2025-10-05 15:07:00Z],
        last_fetched_at: ~U[2025-10-05 15:07:00Z],
        metadata: %{}
      }

      assert {:ok, %Metadata{} = metadata} = Cache.create_metadata(valid_attrs)
      assert metadata.api_quota_remaining == 42
      assert metadata.cache_key == "some cache_key"
      assert metadata.cache_type == "some cache_type"
      assert metadata.expires_at == ~U[2025-10-05 15:07:00Z]
      assert metadata.last_fetched_at == ~U[2025-10-05 15:07:00Z]
      assert metadata.metadata == %{}
    end

    test "create_metadata/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Cache.create_metadata(@invalid_attrs)
    end

    test "update_metadata/2 with valid data updates the metadata" do
      metadata = metadata_fixture()

      update_attrs = %{
        api_quota_remaining: 43,
        cache_key: "some updated cache_key",
        cache_type: "some updated cache_type",
        expires_at: ~U[2025-10-06 15:07:00Z],
        last_fetched_at: ~U[2025-10-06 15:07:00Z],
        metadata: %{}
      }

      assert {:ok, %Metadata{} = metadata} = Cache.update_metadata(metadata, update_attrs)
      assert metadata.api_quota_remaining == 43
      assert metadata.cache_key == "some updated cache_key"
      assert metadata.cache_type == "some updated cache_type"
      assert metadata.expires_at == ~U[2025-10-06 15:07:00Z]
      assert metadata.last_fetched_at == ~U[2025-10-06 15:07:00Z]
      assert metadata.metadata == %{}
    end

    test "update_metadata/2 with invalid data returns error changeset" do
      metadata = metadata_fixture()
      assert {:error, %Ecto.Changeset{}} = Cache.update_metadata(metadata, @invalid_attrs)
      assert metadata == Cache.get_metadata!(metadata.id)
    end

    test "delete_metadata/1 deletes the metadata" do
      metadata = metadata_fixture()
      assert {:ok, %Metadata{}} = Cache.delete_metadata(metadata)
      assert_raise Ecto.NoResultsError, fn -> Cache.get_metadata!(metadata.id) end
    end

    test "change_metadata/1 returns a metadata changeset" do
      metadata = metadata_fixture()
      assert %Ecto.Changeset{} = Cache.change_metadata(metadata)
    end
  end
end
