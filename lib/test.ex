defmodule Test do
  @spec test(%{number: integer()}) :: integer()
  def test(%{number: number}) when is_integer(number) do
    number
  end
end
