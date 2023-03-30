defmodule Plejady.TestingTest do
  use Plejady.DataCase

  alias Plejady.Testing

  describe "test" do
    alias Plejady.Testing.Test

    import Plejady.TestingFixtures

    @invalid_attrs %{name: nil}

    test "list_test/0 returns all test" do
      test = test_fixture()
      assert Testing.list_test() == [test]
    end

    test "get_test!/1 returns the test with given id" do
      test = test_fixture()
      assert Testing.get_test!(test.id) == test
    end

    test "create_test/1 with valid data creates a test" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Test{} = test} = Testing.create_test(valid_attrs)
      assert test.name == "some name"
    end

    test "create_test/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Testing.create_test(@invalid_attrs)
    end

    test "update_test/2 with valid data updates the test" do
      test = test_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Test{} = test} = Testing.update_test(test, update_attrs)
      assert test.name == "some updated name"
    end

    test "update_test/2 with invalid data returns error changeset" do
      test = test_fixture()
      assert {:error, %Ecto.Changeset{}} = Testing.update_test(test, @invalid_attrs)
      assert test == Testing.get_test!(test.id)
    end

    test "delete_test/1 deletes the test" do
      test = test_fixture()
      assert {:ok, %Test{}} = Testing.delete_test(test)
      assert_raise Ecto.NoResultsError, fn -> Testing.get_test!(test.id) end
    end

    test "change_test/1 returns a test changeset" do
      test = test_fixture()
      assert %Ecto.Changeset{} = Testing.change_test(test)
    end
  end
end
