defmodule Solution do
  @max 4_294_967_296

  def part1() do
    blacklist() |> hd() |> Enum.at(1) |> then(&(&1 + 1))
  end

  def part2() do
    blacklist()
    |> Enum.reduce(0, fn [x, y], acc -> acc + y - x + 1 end)
    |> then(&(@max - &1))
  end

  def blacklist() do
    input() |> Enum.reduce([], &merge/2)
  end

  def merge(pair, []), do: [pair]

  def merge([a, b], [[x, y] | xs]) do
    cond do
      b < x - 1 -> [[a, b], [x, y] | xs]
      a > y + 1 -> [[x, y] | merge([a, b], xs)]
      true -> merge([min(a, x), max(b, y)], xs)
    end
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.split(&1, "-"))
    |> Stream.map(fn arr -> Enum.map(arr, &String.to_integer/1) end)
    |> Enum.to_list()
  end
end
