defmodule Solution do
  @len 16

  def part1() do
    input()
    |> run(%{}, 0, 1)
  end

  def part2() do
    input()
    |> run(%{}, 0, 2)
    |> then(fn v -> v - part1() end)
  end

  def run(map, set, steps, times) do
    key = map |> Map.values() |> Enum.join(",")

    if set[key] == times do
      steps
    else
      {i, v} = map |> Enum.max_by(fn {_, v} -> v end)
      map = Map.put(map, i, 0)

      for j <- 1..v, reduce: map do
        acc -> Map.update!(acc, rem(i + j, @len), &(&1 + 1))
      end
      |> run(Map.update(set, key, 1, &(&1 + 1)), steps + 1, times)
    end
  end

  def input() do
    File.stream!("./input.txt")
    |> Enum.to_list()
    |> hd()
    |> String.trim()
    |> String.split()
    |> Enum.map(&String.to_integer/1)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {n, i}, acc ->
      Map.put(acc, i, n)
    end)
  end
end
