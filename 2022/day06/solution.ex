defmodule Solution do
  def part1() do
    input()
    |> aux(4)
  end

  def part2() do
    input()
    |> aux(14)
  end

  def aux(s, n) do
    s
    |> String.graphemes()
    |> Enum.chunk_every(n, 1)
    |> Enum.with_index()
    |> Enum.find(fn {lst, _i} ->
      lst |> MapSet.new() |> MapSet.size() == n
    end)
    |> then(fn {lst, i} -> length(lst) + i end)
  end

  def input() do
    File.stream!("./input.txt")
    |> Enum.to_list()
    |> hd()
    |> String.trim()
  end
end
