defmodule GrovePi.I2C.StateTest do
  use ExUnit.Case, async: true

  alias GrovePi.{I2C.State, I2C.Write}

  @error {:error, :no_more_messages}

  test "add_input adds a write" do
    state = %State{responses: [], writes: []}
    write = %Write{address: 0x01, data: 0x02}

    new_state = State.add_input(state, write)

    assert Enum.count(new_state.writes) == 1
  end

  test "add_responses adds a response" do
    state = %State{responses: [], writes: []}
    responses = [0x02, 0x03]

    new_state = State.add_responses(state, responses)

    assert Enum.count(new_state.responses) == 2
  end

  test "pop_all_writes return error if no writes" do
    state = %State{responses: [], writes: []}

    result = State.pop_all_writes(state)

    assert  result == {@error, state}
  end

  test "pop_all_writes returns all writes" do
    state =
      %State{responses: [], writes: [
        %Write{address: 0x01, data: 0x02},
        %Write{address: 0x01, data: 0x01},
      ]}

    {writes, new_state} = State.pop_all_writes(state)

    assert Enum.count(writes) == 2
    assert new_state == %State{responses: [], writes: []}
  end

  test "pop_all_date return error if no writes" do
    state = %State{responses: [], writes: []}

    result = State.pop_all_data(state)

    assert  result == {@error, state}
  end

  test "pop_all_data returns all writes" do
    state =
      %State{responses: [], writes: [
        %Write{address: 0x01, data: 0x02},
        %Write{address: 0x01, data: 0x01},
      ]}

    {data, new_state} = State.pop_all_data(state)

    assert data == [0x01, 0x02]
    assert new_state == %State{responses: [], writes: []}
  end

  test "pop_last_write return error if no writes" do
    state = %State{responses: [], writes: []}

    result = State.pop_last_write(state)

    assert  result == {@error, state}
  end

  test "pop_last_write returns last write" do
    state =
      %State{responses: [], writes: [
        %Write{address: 0x01, data: 0x02},
        %Write{address: 0x01, data: 0x01},
      ]}

    {write, new_state} = State.pop_last_write(state)

    assert write.data == 0x02
    assert new_state ==
      %State{responses: [], writes: [
        %Write{address: 0x01, data: 0x01},
      ]}
  end

  test "pop_last_write_data return error if no writes" do
    state = %State{responses: [], writes: []}

    result = State.pop_last_write_data(state)

    assert  result == {@error, state}
  end

  test "pop_last_write_data returns last data" do
    state =
      %State{responses: [], writes: [
        %Write{address: 0x01, data: 0x02},
        %Write{address: 0x01, data: 0x01},
      ]}

    {data, new_state} = State.pop_last_write_data(state)

    assert data == 0x02
    assert new_state ==
      %State{responses: [], writes: [
        %Write{address: 0x01, data: 0x01},
      ]}
  end

  test "pop_last_response returns error if no responses" do
    state = %State{responses: [], writes: []}

    result = State.pop_last_response(state)

    assert result == {@error, state}
  end

  test "pop_last_response returns last response" do
    state = %State{responses: [0x02, 0x03], writes: []}

    {response, new_state} = State.pop_last_response(state)

    assert response == 0x02
    assert new_state == %State{responses: [0x03], writes: []}
  end
end
