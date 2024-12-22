defmodule Solution do
  def part1() do
    input()
    |> Enum.map(fn n ->
      1..2000
      |> Enum.reduce(n, fn _, n -> evolve(n) end)
    end)
    |> Enum.sum()
  end

  def part2() do
    lst =
      input()
      |> Enum.map(fn n ->
        Stream.iterate(n, &evolve/1)
        |> Stream.map(&rem(&1, 10))
        |> Enum.take(2001)
        |> Enum.chunk_every(5, 1, :discard)
        |> Enum.reduce(%{}, fn [a, b, c, d, e], acc ->
          Map.put_new(acc, [b - a, c - b, d - c, e - d], e)
        end)
      end)

    lst
    |> Enum.reduce(%MapSet{}, fn mp, acc ->
      Map.keys(mp)
      |> MapSet.new()
      |> MapSet.union(acc)
    end)
    |> Enum.reduce(0, fn seq, acc ->
      lst
      |> Enum.reduce(0, fn mp, acc ->
        acc + Map.get(mp, seq, 0)
      end)
      |> max(acc)
    end)
  end

  def evolve(n) do
    n = mix(n, n * 64) |> prune()
    n = div(n, 32) |> mix(n) |> prune()
    mix(n * 2048, n) |> prune()
  end

  def mix(a, b), do: Bitwise.bxor(a, b)

  def prune(n), do: rem(n, 16_777_216)

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.to_integer/1)
  end
end
