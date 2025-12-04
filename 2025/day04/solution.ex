defmodule Solution do
  def part1() do
    st = input()

    Enum.count(st, &(neighbors(st, &1) < 4))
  end

  def part2() do
    input() |> try_remove()
  end

  def try_remove(st, acc \\ 0) do
    case MapSet.filter(st, &(neighbors(st, &1) >= 4)) do
      ^st -> acc
      removed -> try_remove(removed, acc + MapSet.size(st) - MapSet.size(removed))
    end
  end

  def neighbors(st, {i, j}) do
    for x <- -1..1, y <- -1..1, x != 0 or y != 0, reduce: 0 do
      acc ->
        acc + if {i + x, j + y} in st, do: 1, else: 0
    end
  end

  def input() do
    File.read!("./input.txt")
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.reduce(%MapSet{}, fn {row, i}, acc ->
      row
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {c, j}, acc ->
        if c == "@", do: MapSet.put(acc, {i, j}), else: acc
      end)
    end)
  end
end
