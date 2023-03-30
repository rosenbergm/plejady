defmodule Plejady.Config do
  @moduledoc """
  Provides the model and logic for the application config.

  Uses a GenServer to store the config in memory and provide a simple API for accessing and updating it.
  """
  alias Plejady.Config.Schema
  use GenServer

  @impl true
  def init(:ok) do
    {:ok, Schema.default()}
  end

  @impl true
  def handle_call(:get, _from, config) do
    formatted_config = config
    # TODO: WTF is this?
    # |> Map.update(:timed_release, nil, fn e ->
    #   if is_nil(e) do
    #     nil
    #   else
    #     DateTime.shift_zone!(e, "Europe/Prague", Tz.TimeZoneDatabase)
    #   end
    # end)

    {:reply, formatted_config, config}
  end

  @impl true
  def handle_cast({:update, new_config}, _config) do
    {:noreply, new_config}
  end

  @doc """
  Starts the `Plejady.Config` GenServer implementation.
  """
  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: Plejady.Config)
  end

  @doc """
  Fetches the current config.
  """
  def get_config() do
    GenServer.call(__MODULE__, :get)
  end

  @doc """
  Updates the current config.
  """
  def set_config(new_config) do
    GenServer.cast(__MODULE__, {:update, new_config})
  end

  defmodule Schema do
    @moduledoc """
    Model and helpers for the `Plejady.Config` schema.
    """
    use Ecto.Schema
    import Ecto.Changeset

    alias Plejady.Config.Schema

    embedded_schema do
      field :is_open, :boolean, default: false
      field :timed_release, :utc_datetime, default: nil
      field :guest_capacity, :integer, default: 30
    end

    @doc """
    Creates a changeset based on the `Schema` struct and `params`.
    """
    def changeset(schema, params \\ %{}) do
      schema
      |> cast(params, [:timed_release, :is_open, :guest_capacity])
    end

    @doc """
    The default value for a config.
    """
    def default do
      %Schema{
        is_open: false,
        # TODO: Figure this out
        # timed_release: nil,
        timed_release: DateTime.utc_now(),
        guest_capacity: 30
      }
    end

    @doc """
    Returns a new config.
    """
    def new(is_open, open_at_time) do
      %Schema{
        is_open: is_open,
        timed_release: open_at_time
      }
    end

    @doc """
    Returns a changeset with the updated guest capacity
    """
    def update_guest_capacity(config, new_capacity) do
      config
      |> change(guest_capacity: new_capacity)
    end

    @doc """
    Takes the parameters from the form and returns a Config struct.
    """
    def from_changeset(params) do
      params
      |> Map.update("timed_release", nil, fn e ->
        if e == "" do
          nil
        else
          NaiveDateTime.from_iso8601!(e <> ":00.000Z")
          |> DateTime.from_naive!("Europe/Prague", Tz.TimeZoneDatabase)
          |> DateTime.shift_zone!("Etc/UTC")
          |> DateTime.to_string()
        end
      end)
      |> changeset()
      |> change(is_open: false)
      |> apply_changes()
    end
  end
end
