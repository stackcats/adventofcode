defmodule Solution do
  def part1() do
    input()
    |> Enum.reduce({0, 0, -1, 0}, fn {d, n}, {x, y, dx, dy} ->
      {dx, dy} =
        case d do
          "R" -> turn_right(dx, dy)
          "L" -> turn_left(dx, dy)
        end

      {x + dx * n, y + dy * n, dx, dy}
    end)
    |> then(fn {x, y, _, _} -> abs(x) + abs(y) end)
  end

  def part2() do
    input()
    |> Enum.reduce_while({0, 0, -1, 0, MapSet.new([{0, 0}])}, fn {d, n}, {x, y, dx, dy, acc} ->
      {dx, dy} =
        case d do
          "R" -> turn_right(dx, dy)
          "L" -> turn_left(dx, dy)
        end

      x = x + dx * n
      y = y + dy * n

      if MapSet.member?(acc, {x, y}) do
        {:halt, abs(x) + abs(y)}
      else
        {:cont, {x, y, dx, dy, MapSet.put(acc, {x, y})}}
      end
    end)
  end

  def turn_left(dx, dy) do
    cond do
      dx == -1 -> {0, -1}
      dx == 1 -> {0, 1}
      dy == -1 -> {1, 0}
      dy == 1 -> {-1, 0}
    end
  end

  def turn_right(dx, dy) do
    cond do
      dx == -1 -> {0, 1}
      dx == 1 -> {0, -1}
      dy == -1 -> {-1, 0}
      dy == 1 -> {1, 0}
    end
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.replace(&1, " ", ""))
    |> Stream.map(&String.split(&1, ","))
    |> Enum.to_list()
    |> hd()
    |> Enum.map(fn s ->
      Regex.named_captures(~r/(?<d>(R|L))(?<n>\d+)/, s)
      |> then(fn m ->
        {m["d"], String.to_integer(m["n"])}
      end)
    end)
  end
end
