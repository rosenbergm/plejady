defmodule Plejady.TestingFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Plejady.Testing` context.
  """

  @doc """
  Generate a test.
  """
  def test_fixture(attrs \\ %{}) do
    {:ok, test} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Plejady.Testing.create_test()

    test
  end
end
