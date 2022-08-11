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
    |> Enum.reduce_while({0, 0, -1, 0, MapSet.new()}, fn {d, n}, {x, y, dx, dy, acc} ->
      {dx, dy} =
        case d do
          "R" -> turn_right(dx, dy)
          "L" -> turn_left(dx, dy)
        end

      case has_line?(acc, 0, n, x, y, dx, dy) do
        {x, y} -> {:halt, abs(x) + abs(y)}
        set -> {:cont, {x + n * dx, y + n * dy, dx, dy, set}}
      end
    end)
  end

  def has_line?(set, n, n, _x, _y, _dx, _dy) do
    set
  end

  def has_line?(set, i, n, x, y, dx, dy) do
    if MapSet.member?(set, {x, y}) do
      {x, y}
    else
      has_line?(MapSet.put(set, {x, y}), i + 1, n, x + dx, y + dy, dx, dy)
    end
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
