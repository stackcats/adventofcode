defmodule Solution do
  def part1() do
    {x, y} =
      input()
      |> Enum.reduce({0, 0}, fn {cmd, units}, {x, y} ->
        case cmd do
          "forward" -> {x + units, y}
          "down" -> {x, y + units}
          "up" -> {x, y - units}
        end
      end)

    x * y
  end

  def part2 do
    {x, y, _} =
      input()
      |> Enum.reduce({0, 0, 0}, fn {cmd, units}, {x, y, z} ->
        case cmd do
          "forward" -> {x + units, y + z * units, z}
          "down" -> {x, y, z + units}
          "up" -> {x, y, z - units}
        end
      end)

    x * y
  end

  defp input() do
    File.stream!("./input.txt")
    |> Stream.map(fn line ->
      [cmd, units] = line |> String.trim() |> String.split(" ")
      {cmd, String.to_integer(units)}
    end)
    |> Enum.to_list()
  end
end
