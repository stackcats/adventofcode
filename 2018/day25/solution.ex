defmodule Solution do
  defmodule UnionFind do
    def new() do
      %{}
    end

    def find(uf, t) do
      case uf[t] do
        nil ->
          {t, Map.put(uf, t, t)}

        ^t ->
          {t, uf}

        r ->
          {x, uf} = find(uf, r)
          {x, Map.put(uf, t, x)}
      end
    end

    def union(uf, a, b) do
      {ra, uf} = find(uf, a)
      {rb, uf} = find(uf, b)

      if ra == rb do
        uf
      else
        Map.put(uf, ra, rb)
      end
    end

    def to_set(uf) do
      uf
      |> Map.keys()
      |> Enum.reduce(%MapSet{}, fn k, acc ->
        {r, _} = find(uf, k)
        MapSet.put(acc, r)
      end)
    end
  end

  def part1() do
    lst = input()

    lst
    |> Enum.reduce(%{}, fn a, acc ->
      lst
      |> Enum.reduce(acc, fn b, acc ->
        if manhattan(a, b) <= 3 do
          UnionFind.union(acc, a, b)
        else
          acc
        end
      end)
    end)
    |> UnionFind.to_set()
    |> MapSet.size()
  end

  def manhattan(a, b) do
    Enum.zip(a, b)
    |> Enum.map(fn {x, y} -> abs(x - y) end)
    |> Enum.sum()
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(fn s ->
      s |> String.split(",") |> Enum.map(&String.to_integer/1)
    end)
    |> Enum.to_list()
  end
end
