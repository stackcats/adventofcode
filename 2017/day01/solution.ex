defmodule Solution do
  def part1() do
    xs = input()
    ys = tl(xs) ++ [hd(xs)]

    Enum.zip(xs, ys)
    |> Enum.flat_map(fn {x, y} ->
      if x == y, do: [x], else: []
    end)
    |> Enum.sum()
  end

  def part2() do
    xs = input()
    len = length(xs)

    map =
      (xs ++ xs)
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {x, i}, acc ->
        Map.put(acc, i, x)
      end)

    offset = div(len, 2)

    for i <- 0..(len - 1), reduce: 0 do
      acc -> if map[i] == map[i + offset], do: acc + map[i], else: acc
    end
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Enum.to_list()
    |> hd()
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
  end
end
