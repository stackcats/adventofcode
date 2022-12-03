defmodule Solution do
  def part1() do
    ps = priority()

    input()
    |> Enum.map(fn s ->
      h = s |> String.length() |> div(2)

      s
      |> String.split_at(h)
      |> Tuple.to_list()
      |> find_common()
      |> then(fn c -> Map.get(ps, c) end)
    end)
    |> Enum.sum()
  end

  def part2() do
    ps = priority()

    input()
    |> Enum.chunk_every(3)
    |> Enum.map(fn chunk ->
      chunk
      |> find_common()
      |> then(fn c -> Map.get(ps, c) end)
    end)
    |> Enum.sum()
  end

  def find_common(lst) do
    lst
    |> Enum.map(fn s ->
      s
      |> String.to_charlist()
      |> MapSet.new()
    end)
    |> Enum.reduce(fn m, acc -> MapSet.intersection(acc, m) end)
    |> MapSet.to_list()
    |> hd()
  end

  def priority() do
    l =
      ?a..?z
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {c, i}, acc -> Map.put(acc, c, i + 1) end)

    u =
      ?A..?Z
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {c, i}, acc -> Map.put(acc, c, i + 1 + 26) end)

    Map.merge(l, u)
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Enum.to_list()
  end
end
