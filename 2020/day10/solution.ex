defmodule Solution do
  def part1() do
    input()
    |> List.insert_at(0, 0)
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(fn [a, b] -> b - a end)
    |> Enum.frequencies()
    |> then(fn m -> m[1] * (m[3] + 1) end)
  end

  def part2() do
    adapters = input()
    device = List.last(adapters) + 3
    adapters = adapters ++ [device]

    adapters
    |> Enum.reduce(%{0 => 1}, fn v, dp ->
      1..3
      |> Enum.map(fn i -> Map.get(dp, v - i, 0) end)
      |> Enum.sum()
      |> then(fn s -> Map.put(dp, v, s) end)
    end)
    |> Map.get(device)
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.to_integer/1)
    |> Enum.sort()
  end
end
