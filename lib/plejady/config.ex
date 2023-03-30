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
    formatted_config =
      config
      |> Map.update(:timed_release, nil, &to_czech_timezone/1)

    {:reply, formatted_config, config}
  end

  defp to_czech_timezone(nil), do: nil

  defp to_czech_timezone(datetime) do
    DateTime.shift_zone!(datetime, "Europe/Prague", Tz.TimeZoneDatabase)
  end

  def from_czech_timezone(nil), do: nil

  def from_czech_timezone(form_date) do
    NaiveDateTime.from_iso8601!(form_date <> ":00.000Z")
    |> DateTime.from_naive!("Europe/Prague", Tz.TimeZoneDatabase)
    |> DateTime.shift_zone!("Etc/UTC")
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

    alias Plejady.Config
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
        timed_release: nil,
        # timed_release: DateTime.utc_now(),
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
      params =
        params
        |> Map.update("timed_release", nil, &Config.from_czech_timezone/1)

      %Schema{}
      |> changeset(params)
      |> change(is_open: false)
      |> apply_changes()
    end
  end
end
