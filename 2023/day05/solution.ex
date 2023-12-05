defmodule Solution do
  def part1() do
    {seeds, rst} = input()

    rst
    |> Enum.reduce(seeds, fn lst, acc ->
      acc
      |> Enum.map(fn n ->
        case Enum.find(lst, fn [_, src, range] -> n >= src && n <= src + range end) do
          nil -> n
          [dst, src, _] -> dst + n - src
        end
      end)
    end)
    |> Enum.min()
  end

  def part2() do
    {seeds, rst} = input()

    seeds
    |> Enum.chunk_every(2)
    |> Enum.map(fn [start, len] ->
      rst
      |> Enum.reduce([[start, start + len]], &map_range/2)
      |> Enum.min()
      |> hd()
    end)
    |> Enum.min()
  end

  def map_range(lst, not_mapped, mapped \\ [])

  def map_range([], not_mapped, mapped), do: not_mapped ++ mapped

  def map_range([[dst, src, range] | rs], not_mapped, mapped) do
    not_mapped
    |> Enum.reduce({[], mapped}, fn [start, end_], {not_mapped, mapped} ->
      offset = dst - src
      left = [start, min(end_, src)]
      mapped_center = [max(start, src) + offset, min(end_, src + range) + offset]
      right = [max(start, src + range), end_]
      {add(not_mapped, left) |> add(right), add(mapped, mapped_center)}
    end)
    |> then(fn {not_mapped, mapped} ->
      map_range(rs, not_mapped, mapped)
    end)
  end

  def add(lst, [start, end_]) do
    if end_ > start, do: [[start, end_] | lst], else: lst
  end

  def input() do
    {_, content} = File.read("./input.txt")
    [seeds | rst] = content |> String.trim() |> String.split("\n\n")
    {parse_seeds(seeds), Enum.map(rst, &parse_mapping/1)}
  end

  def parse_seeds(seeds) do
    seeds
    |> String.split(~r/\s+/)
    |> tl()
    |> Enum.map(&String.to_integer/1)
  end

  def parse_mapping(s) do
    s
    |> String.split("\n")
    |> tl()
    |> Enum.map(fn s ->
      s
      |> String.split(~r/\s+/)
      |> Enum.map(&String.to_integer/1)
    end)
  end
end
