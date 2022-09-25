defmodule Solution do
  def part1() do
    input()
    |> aux([])
  end

  def part2() do
    polymer = input()

    for c <- ?a..?z do
      c = List.to_string([c])

      polymer
      |> Enum.filter(fn x ->
        String.downcase(x) != c
      end)
      |> aux([])
    end
    |> Enum.min()
  end

  def aux([], ys) do
    ys |> Enum.count()
  end

  def aux([x | xs], []) do
    aux(xs, [x])
  end

  def aux([x | xs], [y | ys]) do
    if x != y && String.upcase(x) == String.upcase(y) do
      aux(xs, ys)
    else
      aux(xs, [x, y | ys])
    end
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Enum.to_list()
    |> hd()
    |> String.graphemes()

    # |> Enum.with_index()
    # |> Enum.reduce(%{}, fn {c, i}, acc ->
    #   Map.put(acc, i, c)
    # end)
  end
end
