defmodule Solution do
  def part1() do
    input()
    |> Enum.map(fn xs ->
      xs
      |> Enum.min_max()
      |> then(fn {x, y} -> y - x end)
    end)
    |> Enum.sum()
  end

  def part2() do
    input()
    |> Enum.map(fn xs ->
      for x <- xs, y <- xs, x != y, rem(y, x) == 0 do
        div(y, x)
      end
      |> hd()
    end)
    |> Enum.sum()
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.split/1)
    |> Stream.map(fn xs ->
      xs
      |> Enum.map(&String.to_integer/1)
      |> Enum.sort()
    end)
    |> Enum.to_list()
  end
end
