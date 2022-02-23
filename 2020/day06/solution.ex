defmodule Solution do
  def part1() do
    input()
    |> count(&MapSet.union/2)
  end

  def part2() do
    input()
    |> count(&MapSet.intersection/2)
  end

  def count(lst, f) do
    Enum.reduce(lst, 0, fn lst, acc ->
      Enum.reduce(lst, f)
      |> MapSet.size()
      |> then(&(&1 + acc))
    end)
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.chunk_by(&(&1 == ""))
    |> Stream.filter(&(&1 != [""]))
    |> Stream.map(fn lst -> Enum.map(lst, fn s -> s |> String.graphemes() |> MapSet.new() end) end)
    |> Enum.to_list()
  end
end
