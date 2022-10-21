defmodule TripBookingsParser.Segments.Travel do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @primary_key false
  embedded_schema do
    field(:type, :string)
    field(:from, :string)
    field(:to, :string)
    field(:start, :naive_datetime)
    field(:stop, :naive_datetime)
  end

  @spec changeset(t, map) :: Ecto.Changeset.t()
  def changeset(booking, attrs) do
    booking
    |> cast(attrs, [:type, :from, :to, :start, :stop])
    |> validate_required([:type, :from, :to, :start, :stop])
  end

  @spec new(map) :: {:ok, t}
  def new(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
    |> apply_action(:new)
  end
end
