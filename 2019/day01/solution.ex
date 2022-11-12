defmodule Solution do
  def part1() do
    input()
    |> Enum.reduce(0, fn n, acc ->
      acc + fuel(n)
    end)
  end

  def part2() do
    input()
    |> Enum.reduce(0, fn n, acc ->
      acc + fuel(n, true)
    end)
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.to_integer/1)
    |> Enum.to_list()
  end

  def fuel(mass, repeated? \\ false) do
    f = div(mass, 3) - 2

    cond do
      f < 0 -> 0
      repeated? -> f + fuel(f, repeated?)
      true -> f
    end
  end
end
