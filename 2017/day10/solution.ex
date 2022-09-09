defmodule Solution do
  use Bitwise

  def part1() do
    lst =
      input()
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)

    0..255
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {n, i}, acc ->
      Map.put(acc, i, n)
    end)
    |> hash(lst, 0, 0)
    |> elem(0)
    |> then(fn m ->
      m[0] * m[1]
    end)
  end

  def part2() do
    input()
    |> String.graphemes()
    |> Enum.map(&:binary.first/1)
    |> knot()
  end

  def knot(lst, rounds \\ 64) do
    m =
      0..255
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {n, i}, acc ->
        Map.put(acc, i, n)
      end)

    for _ <- 1..rounds, reduce: {m, 0, 0} do
      {m, pos, skip} -> hash(m, lst ++ [17, 31, 73, 47, 23], pos, skip)
    end
    |> elem(0)
    |> then(fn m ->
      for i <- 0..255//16 do
        for j <- i..(i + 15) do
          m[j]
        end
        |> Enum.reduce(&bxor/2)
        |> to_hex()
      end
      |> Enum.join()
    end)
  end

  def hash(m, [], pos, skip), do: {m, pos, skip}

  def hash(m, [x | xs], pos, skip) do
    m = reverse(m, pos, x - 1)
    hash(m, xs, rem(pos + x + skip, map_size(m)), skip + 1)
  end

  def reverse(m, _x, len) when len <= 0, do: m

  def reverse(m, x, len) do
    y = rem(x + len, map_size(m))

    m
    |> Map.put(x, m[y])
    |> Map.put(y, m[x])
    |> reverse(rem(x + 1, map_size(m)), len - 2)
  end

  def input() do
    File.stream!("./input.txt")
    |> Enum.to_list()
    |> hd()
    |> String.trim()
  end

  def to_hex(n) do
    n |> Integer.to_string(16) |> String.pad_leading(2, "0") |> String.downcase()
  end
end
