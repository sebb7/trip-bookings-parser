defmodule TripBookingsParser.Segments.Hotel do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @primary_key false
  embedded_schema do
    field(:location, :string)
    field(:start, :date)
    field(:stop, :date)
  end

  @spec changeset(t, map) :: Ecto.Changeset.t()
  def changeset(booking, attrs) do
    booking
    |> cast(attrs, [:location, :start, :stop])
    |> validate_required([:location, :start, :stop])
  end

  @spec new(map) :: {:ok, t}
  def new(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
    |> apply_action(:new)
  end
end
