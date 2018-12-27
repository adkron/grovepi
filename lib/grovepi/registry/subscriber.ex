defmodule GrovePi.Registry.Subscriber do
  @moduledoc false

  @type event :: atom
  @type package :: any
  @type registration :: {GrovePi.pin(), event}
  @type message :: {GrovePi.pin(), event, package}

  @spec start_link(Registry.registry()) :: Supervisor.on_start()
  def start_link(prefix, opts \\ []) do
    opts =
      opts
      |> Keyword.put(:id, :subscriber_registry)
      |> Keyword.put(:keys, :duplicate)
      |> Keyword.put(:name, registry(prefix))

    Registry.start_link(opts)
  end

  @spec notify_change(atom, message()) :: :ok
  def notify_change(prefix, {pin, event, _} = message) do
    Registry.dispatch(registry(prefix), {pin, event}, fn listeners ->
      for {pid, :ok} <- listeners, do: send(pid, message)
    end)
  end

  @spec subscribe(atom, registration) :: :ok | {:error, {:already_registered, pid}}
  def subscribe(prefix, message) do
    Registry.register(registry(prefix), message, :ok)
  end

  defp registry(prefix) do
    String.to_atom("#{prefix}.#{__MODULE__}")
  end
end
