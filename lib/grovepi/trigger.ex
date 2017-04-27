defmodule GrovePi.Trigger do
  @moduledoc """
  The Trigger behaviour is used for implementing triggers for poller
  behaviors such as `GrovePi.Sound` and `GrovePi.Button`. The triggers
  must implement two callbacks, init and update.
  """

  @type event :: atom
  @type state :: struct

  @doc """
  The init callback that must return `{:ok, state}` or an error tuple.
  """
  @callback init(args :: term) :: {:ok, state} | {:error, reason :: any}

  @doc """
  The update callback receives a new value and a trigger state and returns
  a tuple of `{:event_name, new_state}`.

  If no event is needed to fire return `{:ok, new_state}`.
  """
  @callback update(value :: any, state) :: {:ok, state} | {event, state}

  def __using__(_) do
    quote location: :keep do
      @behaviour GrovePi.Trigger

      def init(args) do
        {:ok, args}
      end
    end
  end
end
