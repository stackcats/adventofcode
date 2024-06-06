defmodule Solution do
  def part1() do
    grid() |> count()
  end

  def part2() do
    grid() |> run(100) |> count()
  end

  def run(g, 0), do: g

  def run(g, ct) do
    g
    |> Enum.reduce(g, fn {p, _}, acc ->
      neighbors(p) |> Enum.reduce(acc, &Map.put_new(&2, &1, false))
    end)
    |> Map.new(fn {p, v} ->
      blacks = neighbors(p) |> Enum.count(&Map.get(g, &1, false))

      if v do
        {p, blacks in 1..2}
      else
        {p, blacks == 2}
      end
    end)
    |> run(ct - 1)
  end

  def count(g) do
    g |> Map.values() |> Enum.count(& &1)
  end

  def grid() do
    input()
    |> Enum.reduce(%{}, fn cmds, acc ->
      cmds
      |> Enum.reduce({0, 0, 0}, fn
        "se", {q, r, s} -> {q, r + 1, s - 1}
        "sw", {q, r, s} -> {q - 1, r + 1, s}
        "ne", {q, r, s} -> {q + 1, r - 1, s}
        "nw", {q, r, s} -> {q, r - 1, s + 1}
        "e", {q, r, s} -> {q + 1, r, s - 1}
        "w", {q, r, s} -> {q - 1, r, s + 1}
      end)
      |> then(fn pos ->
        color = Map.get(acc, pos, false)
        Map.put(acc, pos, not color)
      end)
    end)
  end

  def neighbors({q, r, s}) do
    [
      {q, r + 1, s - 1},
      {q - 1, r + 1, s},
      {q + 1, r - 1, s},
      {q, r - 1, s + 1},
      {q + 1, r, s - 1},
      {q - 1, r, s + 1}
    ]
  end

  def input() do
    File.stream!("input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(fn s ->
      Regex.scan(~r/se|sw|ne|nw|e|w/, s)
      |> List.flatten()
    end)
    |> Enum.to_list()
  end
end
