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

  @callback update(any, state) :: {event, state}

  def __using__(_) do
    quote location: :keep do
      @behaviour GrovePi.Trigger

      def init(args) do
        {:ok, args}
      end
    end
  end
end
