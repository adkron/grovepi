defmodule GrovePi.PollerTest do
  use ComponentTestCase, async: true

  defmodule TestTrigger do
    use GrovePi.Trigger

    def init(_) do
      {:ok, []}
    end

    def update(value, _), do: {:trigger, value}
  end

  defmodule TestPoller do
    use GrovePi.Poller, default_trigger: GrovePi.PollerTest.TestTrigger, read_type: :integer

    def read_value(_, _) do
      1
    end
  end

  setup %{prefix: prefix} = tags do
    poll_interval = Map.get(tags, :poll_interval, 1)

    {:ok, pid} =
      TestPoller.start_link(
        @pin,
        poll_interval: poll_interval,
        prefix: prefix
      )

    tags = Map.put(tags, :poller, pid)
    {:ok, tags}
  end

  test "registering for a an event receives event messages", %{prefix: prefix} do
    TestPoller.subscribe(@pin, :trigger, prefix)

    assert_receive {@pin, :trigger, _}, 300
  end

  @tag poll_interval: 1_000_000
  test "reading notifies subscribers", %{prefix: prefix} do
    TestPoller.subscribe(@pin, :trigger, prefix)

    TestPoller.read(@pin, prefix)

    assert_receive {@pin, :trigger, _}, 10
  end

  @tag poll_interval: 1_000_000
  test "stop polling", %{prefix: prefix, poller: poller} do
    %{poll_reference: reference, poll_interval: 1_000_000} = :sys.get_state(poller)

    assert Process.read_timer(reference)

    assert TestPoller.stop_polling(@pin, prefix) == :ok

    %{poll_reference: nil, poll_interval: 0} = :sys.get_state(poller)

    refute Process.read_timer(reference)
  end

  @tag poll_interval: 1_000_000
  test "changing polling", %{prefix: prefix, poller: poller} do
    %{poll_reference: reference, poll_interval: 1_000_000} = :sys.get_state(poller)

    assert Process.read_timer(reference)

    new_interval = 10_000
    assert TestPoller.change_polling(@pin, new_interval, prefix) == :ok

    %{poll_reference: new_reference, poll_interval: ^new_interval} = :sys.get_state(poller)

    assert Process.read_timer(new_reference)
    refute Process.read_timer(reference)
  end

  @tag poll_interval: 0
  test "no polling does not schedule a polling message", %{poller: poller} do
    %{poll_reference: reference, poll_interval: 0} = :sys.get_state(poller)

    refute reference
  end
end
