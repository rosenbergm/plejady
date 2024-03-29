defmodule Plejady.Config do
  @moduledoc """
  Provides the model and logic for the application config.

  Uses a GenServer to store the config in memory and provide a simple API for accessing and updating it.
  """
  alias Plejady.Config.Schema
  use GenServer

  import Ecto.Changeset

  @impl true
  def init(:ok) do
    {:ok, Schema.default()}
  end

  @impl true
  def handle_call(:get, _from, config) do
    formatted_config =
      config
      |> Map.update(:timed_release, nil, &to_czech_timezone/1)
      |> Map.update(:timed_release_end, nil, &to_czech_timezone/1)

    {:reply, formatted_config, config}
  end

  defp to_czech_timezone(nil), do: nil

  defp to_czech_timezone(datetime) do
    Timex.Timezone.convert(datetime, "Europe/Prague")
  end

  def from_czech_timezone(nil), do: nil

  def from_czech_timezone(form_date) do
    {:ok, naive} = Timex.parse(form_date, "%Y-%m-%dT%H:%M", :strftime)

    Timex.Timezone.convert(naive, "Europe/Prague")
    |> Timex.Timezone.convert("UTC")
  end

  @impl true
  def handle_cast({:set, new_config}, _config) do
    {:noreply, new_config}
  end

  @impl true
  def handle_cast({:update, params}, config) do
    {:noreply, config |> Schema.changeset(params) |> apply_changes()}
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
  Sets the current config.
  """
  def set_config(new_config) do
    GenServer.cast(__MODULE__, {:set, new_config})
  end

  @doc """
  Updates the current config.
  """
  def update_config(params) do
    GenServer.cast(__MODULE__, {:update, params})
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
      field :has_ended, :boolean, default: false
      field :timed_release, :utc_datetime, default: nil
      field :timed_release_end, :utc_datetime, default: nil
      field :guest_capacity, :integer, default: 30
    end

    @doc """
    Creates a changeset based on the `Schema` struct and `params`.
    """
    def changeset(schema, params \\ %{}) do
      schema
      |> cast(params, [:timed_release, :timed_release_end, :is_open, :has_ended, :guest_capacity])
    end

    @doc """
    The default value for a config.
    """
    def default do
      %Schema{
        is_open: false,
        timed_release: nil,
        timed_release_end: nil,
        guest_capacity: 30
      }
    end

    @doc """
    Returns a new config.
    """
    def new(is_open, open_at_time, close_at_time) do
      %Schema{
        is_open: is_open,
        timed_release: open_at_time,
        timed_release_end: close_at_time
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
        |> Map.update("timed_release_end", nil, &Config.from_czech_timezone/1)

      %Schema{}
      |> changeset(params)
      |> change(is_open: false)
      |> apply_changes()
    end
  end
end
