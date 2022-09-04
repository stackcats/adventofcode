defmodule Solution do
  def part1() do
    input()
    |> run(0, 0, fn v -> v + 1 end)
  end

  def part2() do
    input()
    |> run(0, 0, fn v ->
      if v >= 3, do: v - 1, else: v + 1
    end)
  end

  def run(map, i, steps, func) do
    if map[i] == nil do
      steps
    else
      map
      |> Map.update!(i, func)
      |> run(i + map[i], steps + 1, func)
    end
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.to_integer/1)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {n, i}, acc ->
      Map.put(acc, i, n)
    end)
  end
end
