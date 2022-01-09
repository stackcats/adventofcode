defmodule Solution do
  def part1() do
    {_, _, y1, _} = input()
    y = -y1 - 1
    div((1 + y) * y, 2)
  end

  def part2() do
    {_, x2, y1, _} = target = input()

    for x <- x2..0, y <- y1..-y1, reduce: 0 do
      acc -> aux(x, y, x, y, target) + acc
    end
  end

  def aux(x, y, dx, dy, {x1, x2, y1, y2} = target) do
    cond do
      x > x2 or y < y1 ->
        0

      x >= x1 and x <= x2 and y >= y1 and y <= y2 ->
        1

      true ->
        dx = max(dx - 1, 0)
        dy = dy - 1
        aux(x + dx, y + dy, dx, dy, target)
    end
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Enum.to_list()
    |> List.first()
    |> parse()
  end

  def parse(s) do
    m =
      ~r/target area: x=(?<x1>\d*)..(?<x2>\d*), y=(?<y1>[\d-]*)..(?<y2>[\d-]*)/
      |> Regex.named_captures(s)
      |> Enum.map(fn {k, v} -> {k, String.to_integer(v)} end)
      |> Enum.into(%{})

    {m["x1"], m["x2"], m["y1"], m["y2"]}
  end
end
