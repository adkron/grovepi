defmodule GrovePi.Buttons do
  use Supervisor
  @name __MODULE__

  @moduledoc """
  Buttons are a great way to add some interactivity to your grove project.
  The GrovePi.Buttons module gives two options for reacting to button
  presses and releases.

  GrovePi.Buttons uses [Registry](https://hexdocs.pm/elixir/master/Registry.html)
  to dispatch pressed and released events to interested modules. This means that
  the interested modules must be local. If you need to notify remote nodes you
  will need to have a module to relay the events to the external nodes.

  Starting The Registry
  =====================

  iex> {:ok, pid} = GrovePi.start_link
  {:ok, #PID<0.172.0>}

  iex> GrovePi.Buttons.start_link(pid)
  {:ok, #PID<0.173.0>}

  Adding A Button to a Pin
  ========================

  iex> pin = 2

  iex> GrovePi.Buttons.add(pin)
  {:ok, #PID<0.187.0>}

  Registering to Receive Messages
  ===============================

  The messages will be sent to the process that calls
  `GrovePi.Buttons.register\1`.

  iex> GrovePi.Buttons.register({:pressed, pin})
  {:ok, #PID<0.178.0>}

  iex> GrovePi.Buttons.register({:released, pin})
  {:ok, #PID<0.178.0>}

  #press and release a button attached to pin 2

  iex> flush()
  {:pressed, 2}
  {:released, 2}

  Alternatively an mfa may be registered instead of using messages the pid
  of the registering process will be added as the first argument to the
  function

  Registering A Module Callback
  =============================

    defmodule MyModule do
      def my_function(registered_pid, arg1, arg2) do
        # ...
      end
    end

  iex> GrovePi.Buttons.register({:released, pin}, {MyModule, :my_function, ["one", 2]})
  """

  @type event :: :pressed | :released
  @type pin :: integer
  @type message :: {event, pin}

  @spec start_link(pid, Supervisor.options) :: Supervisor.on_start
  def start_link(grove_pi_pid, opts \\ []) do
    opts = Keyword.put_new(opts, :name, @name)
    Supervisor.start_link(__MODULE__, [grove_pi_pid], opts)
  end

  def init([grove_pi_pid]) do
    children = [
      supervisor(GrovePi.Buttons.Registry, []),
      supervisor(GrovePi.Buttons.Supervisor, [grove_pi_pid]),
    ]

    supervise(children, strategy: :one_for_one)
  end

  @spec add(pin) :: Supervisor.on_start
  def add(pin) do
    GrovePi.Buttons.Supervisor.add(pin)
  end

  @spec register(message, :ok | mfa) :: {:ok, pid} | {:error, {:already_registered, pid}}
  def register(message, mfa \\ :ok) do
    GrovePi.Buttons.Registry.register(message, mfa)
  end

  @spec notify_change(pin, GrovePi.Button.change) :: :ok
  def notify_change(pin, {last_value, 1}) when last_value != 1 do
    GrovePi.Buttons.Registry.dispatch({:pressed, pin})
  end

  def notify_change(pin, {last_value, 0}) when last_value != 0 do
    GrovePi.Buttons.Registry.dispatch({:released, pin})
  end

  def notify_change(_pin, {current_value, current_value}), do: :ok
end
