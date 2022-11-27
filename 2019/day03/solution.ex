defmodule Solution do
  def part1() do
    [w1, w2] = input()

    p1 = w1 |> run()
    p2 = w2 |> run()

    p1
    |> Enum.filter(fn {k, _} -> p2[k] != nil end)
    |> Enum.min_by(fn {k, _} -> manhattan(k) end)
    |> elem(0)
    |> manhattan()
  end

  def part2() do
    [w1, w2] = input()

    p1 = w1 |> run()
    p2 = w2 |> run()

    p1
    |> Enum.filter(fn {k, _} -> p2[k] != nil end)
    |> Enum.min_by(fn {k, v} -> v + p2[k] end)
    |> then(fn {k, v} -> v + p2[k] end)
  end

  def run(path) do
    path
    |> Enum.reduce({%{}, 0, 0, 0}, fn {d, steps}, {acc, x, y, ct} ->
      {dx, dy} =
        case d do
          "U" -> {-1, 0}
          "D" -> {1, 0}
          "L" -> {0, -1}
          "R" -> {0, 1}
        end

      for _ <- 1..steps, reduce: {acc, x, y, ct} do
        {acc, x, y, ct} ->
          x = x + dx
          y = y + dy
          ct = ct + 1
          {Map.put_new(acc, {x, y}, ct), x, y, ct}
      end
    end)
    |> elem(0)
  end

  def manhattan({x, y}) do
    abs(x) + abs(y)
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.split(&1, ","))
    |> Stream.map(fn xs ->
      xs
      |> Enum.map(fn x ->
        r = ~r/(?<dir>(R|U|D|L))(?<steps>\d+)/

        Regex.named_captures(r, x)
        |> then(fn m ->
          {m["dir"], String.to_integer(m["steps"])}
        end)
      end)
    end)
    |> Enum.to_list()
  end
end
