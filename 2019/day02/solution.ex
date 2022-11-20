defmodule Solution do
  def part1() do
    input()
    |> Map.put(1, 12)
    |> Map.put(2, 2)
    |> run(0)
  end

  def part2() do
    mp = input()

    for noun <- 0..99, verb <- 0..99 do
      {noun, verb}
    end
    |> Enum.find(fn {n, v} ->
      mp
      |> Map.put(1, n)
      |> Map.put(2, v)
      |> run(0)
      |> then(fn m -> m == 19_690_720 end)
    end)
    |> then(fn {n, v} -> n * 100 + v end)
  end

  def run(mp, i) do
    a = mp[mp[i + 1]]
    b = mp[mp[i + 2]]

    case mp[i] do
      99 -> mp[0]
      1 -> mp |> Map.put(mp[i + 3], a + b) |> run(i + 4)
      2 -> mp |> Map.put(mp[i + 3], a * b) |> run(i + 4)
    end
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Enum.to_list()
    |> hd()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {n, i}, acc ->
      Map.put(acc, i, n)
    end)
  end
end
