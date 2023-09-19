defmodule Plejady.Registry do
  @moduledoc """
  This module is responsible for managing the registry of presentations and their occupancy. It provides a super fast read-write cache for the real-time component of the app with fire-and-forget requests to the database for permanent storage.

  The `Plejady.Registry` struct is considered a source of truth for the app while running. It is prefetched with data from the database to avoid thousands of lookup requests.

  Next, it provides utility functions for fetching the occupancy of a presentation.
  """
  alias Plejady.Registration

  @cache :registry

  @enforce_keys [:presentations, :rooms, :timeblocks]
  defstruct [:presentations, :rooms, :timeblocks]

  @type t :: %Plejady.Registry{
          presentations: list(Plejady.Presentation.t()),
          rooms: list(Plejady.Room.t()),
          timeblocks: list(Plejady.Timeblock.t())
        }

  @doc """
  Returns the statically-defined name of the cache used by the registry.
  """
  def cache_name, do: @cache

  @doc """
  Creates a new registry struct.
  """
  def new(presentations, rooms, timeblocks) do
    %Plejady.Registry{
      presentations: presentations,
      rooms: rooms,
      timeblocks: timeblocks
    }
  end

  @doc """
  Fetches the registry from the cache.
  """
  def get do
    Cachex.get(@cache, :registry)
    |> case do
      {:ok, nil} ->
        {:error, :not_found}

      otherwise ->
        otherwise
    end
  end

  @doc """
  Clears the cache.
  """
  def clear do
    Cachex.clear(@cache)
  end

  @spec fetch_signed_users(String.t()) :: {String.t(), {atom, any}}
  defp fetch_signed_users(presentation_id) do
    {presentation_id, Cachex.get(@cache, presentation_id)}
  end

  defp fetch_occupancy_for_presentation(presentation_id) do
    {_, cache_response} = fetch_signed_users(presentation_id)

    case cache_response do
      {:ok, users} when is_list(users) ->
        {:ok, length(users)}

      otherwise ->
        otherwise
    end
  end

  @doc """
  Fetches the occupancy of all presentations.

  Returns a map where keys are `Plejady.Presentation` ids and values are the number of signed users.
  """
  def fetch_occupancy do
    {:ok, registry} = get()

    registry.presentations
    |> Enum.map(&Task.async(fn -> {&1.id, fetch_occupancy_for_presentation(&1.id)} end))
    |> Task.await_many()
    |> Enum.reduce({:ok, []}, fn {presentation_id, cache_response}, {_state, acc} ->
      case cache_response do
        {:ok, nil} ->
          # If key is not present, for example when the season is launched
          {:ok, [{presentation_id, 0} | acc]}

        {:ok, capacity} ->
          # Occupancy was successfully retrieved and passed into the registry
          {:ok, [{presentation_id, capacity} | acc]}

        _ ->
          # Some state that should never occur. Not documented in Cachex.
          {:error, acc}
      end
    end)
    |> case do
      {:ok, result} ->
        Map.new(result)

      _ ->
        %{}
    end
  end

  @doc """
  Returns a list of `Plejady.Presentation` ids that a user specified by `user_id` is signed up for.
  """
  def fetch_signed_up_for(registry, user_id) do
    registry.presentations
    |> Enum.reduce([], fn %{id: id}, acc ->
      with {_, cache_response} <- fetch_signed_users(id),
           {:ok, users} when not is_nil(users) <- cache_response do
        if user_id in users,
          do: [id | acc],
          else: acc
      else
        _ ->
          acc
      end
    end)
  end

  @spec update(
          signed_up_for :: list(String.t()),
          presentation_id :: String.t(),
          user_id :: String.t()
        ) :: {:ok, list(String.t())} | {:error, reason :: :full | atom}
  def update(signed_up_for, presentation_id, user_id) do
    {:ok, registry} = get()

    case get_next_state(registry, user_id, presentation_id) do
      {:ok, {:moved, from, to}} ->
        Cachex.transaction(@cache, [from, to], fn worker ->
          with {:commit, _} <-
                 Cachex.get_and_update(worker, to, fn users ->
                   to_presentation = Enum.find(registry.presentations, nil, &(&1.id == to))

                   max_capacity =
                     to_presentation.capacity ||
                       Enum.find(registry.rooms, nil, &(&1.id == to_presentation.room_id)).capacity

                   if length(users) == max_capacity do
                     {:ignore, :max_capacity}
                   else
                     {:commit, [user_id | users]}
                   end
                 end),
               {:commit, _} <- Cachex.get_and_update(worker, from, &List.delete(&1, user_id)) do
            :ok
          else
            {:ignore, :max_capacity} ->
              :full

            _ ->
              :cache_error
          end
        end)
        |> case do
          {:ok, :ok} ->
            Task.start(fn ->
              Registration.move(from, to, user_id)
            end)

            {:ok, [to | signed_up_for |> List.delete(from)]}

          {:ok, :full} ->
            {:error, :full}

          {:ok, :cache_error} ->
            {:error, :cache_error}

          _ ->
            {:error, :unknown}
        end

      {:ok, {:signed, to}} ->
        Cachex.transaction(@cache, [to], fn worker ->
          Cachex.get_and_update(worker, to, fn users ->
            to_presentation = Enum.find(registry.presentations, nil, &(&1.id == to))

            max_capacity =
              to_presentation.capacity ||
                Enum.find(registry.rooms, nil, &(&1.id == to_presentation.room_id)).capacity

            if length(users) >= max_capacity do
              {:ignore, :max_capacity}
            else
              {:commit, [user_id | users]}
            end
          end)
          |> case do
            {:commit, _} ->
              :ok

            {:ignore, :max_capacity} ->
              :full

            _ ->
              :cache_error
          end
        end)
        |> case do
          {:ok, :ok} ->
            Task.start(fn ->
              Registration.new(to, user_id)
            end)

            {:ok, [to | signed_up_for]}

          {:ok, :full} ->
            {:error, :full}

          {:ok, :cache_error} ->
            {:error, :cache_error}

          _ ->
            {:error, :unknown}
        end

      :error ->
        {:error, :next_state}
    end
  end

  @spec get_next_state(
          registry :: Plejady.Registry.t(),
          user_id :: String.t(),
          presentation_id :: String.t()
        ) ::
          {:ok, {:moved, from :: String.t(), to :: String.t()} | {:signed, to :: String.t()}}
          | :error
  defp get_next_state(
         %Plejady.Registry{presentations: presentations},
         user_id,
         presentation_id
       ) do
    cache = fetch_cache(presentations)

    to_presentation = Enum.find(presentations, nil, &(&1.id == presentation_id))

    signed_in_presentations =
      Enum.reduce(cache, [], fn {pres_id, users}, acc ->
        if user_id in users do
          [pres_id | acc]
        else
          acc
        end
      end)

    signed_presentation_in_conflicting_timbelock =
      Enum.find(presentations, nil, fn %{id: pres_id, timeblock_id: timeblock_id} ->
        if pres_id in signed_in_presentations do
          to_presentation.timeblock_id == timeblock_id
        end
      end)

    cond do
      !signed_presentation_in_conflicting_timbelock ->
        {:ok, {:signed, to_presentation.id}}

      %{id: from_id} = signed_presentation_in_conflicting_timbelock ->
        {:ok, {:moved, from_id, to_presentation.id}}

      true ->
        :error
    end
  end

  defp fetch_cache(presentations) do
    presentations
    |> Enum.map(&Task.async(fn -> fetch_signed_users(&1.id) end))
    |> Task.await_many()
    |> Enum.reduce({:ok, []}, fn {presentation_id, cache_response}, {_state, acc} ->
      case cache_response do
        {:ok, nil} ->
          # If key is not present, for example when the season is launched
          {:ok, [{presentation_id, []} | acc]}

        {:ok, users} ->
          # Occupancy was successfully retrieved and passed into the registry
          {:ok, [{presentation_id, users} | acc]}

        _ ->
          # Some state that should never occur. Not documented in Cachex.
          {:error, acc}
      end
    end)
    |> case do
      {:ok, result} ->
        Map.new(result)

      _ ->
        %{}
    end
  end
end
