defmodule GrovePi.Registry.SubscriberTest do
  use ComponentTestCase, async: true
  alias GrovePi.Registry.Subscriber

  test "subscribing then gets messages sent with data on notification", %{prefix: prefix} do
    {:ok, _} = Subscriber.subscribe(prefix, {@pin, :event})

    Subscriber.notify_change(prefix, {@pin, :event, :my_data})

    assert_receive {@pin, :event, :my_data}, 10
  end
end
