defmodule Solution do
  def part1() do
    {xs, ys} = input()

    Enum.zip(Enum.sort(xs), Enum.sort(ys))
    |> Enum.map(fn {x, y} -> abs(x - y) end)
    |> Enum.sum()
  end

  def part2() do
    {xs, ys} = input()

    ys = Enum.frequencies(ys)

    Enum.map(xs, fn x -> x * Map.get(ys, x, 0) end)
    |> Enum.sum()
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(fn s ->
      s
      |> String.trim()
      |> String.split("   ")
      |> Enum.map(&String.to_integer/1)
    end)
    |> Enum.reduce({[], []}, fn [x, y], {xs, ys} ->
      {[x | xs], [y | ys]}
    end)
  end
end
