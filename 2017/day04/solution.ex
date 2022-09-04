defmodule Solution do
  def part1() do
    input()
    |> Enum.filter(fn xs ->
      MapSet.new(xs) |> MapSet.size() == length(xs)
    end)
    |> Enum.count()
  end

  def part2() do
    input()
    |> Enum.filter(fn xs ->
      xs
      |> Enum.map(fn s ->
        s |> String.graphemes() |> Enum.sort() |> Enum.join()
      end)
      |> MapSet.new()
      |> MapSet.size() == length(xs)
    end)
    |> Enum.count()
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.split/1)
    |> Enum.to_list()
  end
end
