defmodule LiveDataTest do
  use ExUnit.Case
  doctest LiveData

  test "greets the world" do
    assert LiveData.hello() == :world
  end
end
