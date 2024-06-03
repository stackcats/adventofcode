defmodule Solution do
  def part1() do
    [card, door] = input()

    1..loop_size(card)
    |> Enum.reduce(1, fn _, acc -> transform(acc, door) end)
  end

  def transform(n, i \\ 7) do
    rem(n * i, 20_201_227)
  end

  def loop_size(pk) do
    Stream.iterate({0, 1}, fn {n, acc} -> {n + 1, transform(acc)} end)
    |> Stream.drop_while(fn {_, acc} -> acc != pk end)
    |> Enum.take(1)
    |> hd()
    |> elem(0)
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.to_integer/1)
    |> Enum.to_list()
  end
end
