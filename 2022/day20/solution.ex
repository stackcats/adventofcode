defmodule Solution do
  def part1() do
    loop(1, 1)
  end

  def part2() do
    loop(811_589_153, 10)
  end

  def loop(factor, ct) do
    lst = input(factor)
    size = length(lst)
    mixed = Enum.reduce(1..ct, lst, fn _, acc -> mix(acc, size) end)
    ndx = Enum.find_index(mixed, fn {n, _} -> n == 0 end)

    1..3
    |> Enum.reduce(0, fn i, acc ->
      {n, _} = Enum.at(mixed, rem(ndx + i * 1000, size))
      acc + n
    end)
  end

  def mix(lst, size) do
    0..(size - 1)
    |> Enum.reduce(lst, fn id, acc ->
      ndx = Enum.find_index(acc, fn {_, i} -> i == id end)
      {n, _} = Enum.at(acc, ndx)
      count = Integer.mod(n, size - 1)
      offset = if ndx + count >= size, do: 1, else: 0
      target = rem(ndx + count, size) + offset
      acc |> List.delete_at(ndx) |> List.insert_at(target, {n, id})
    end)
  end

  def input(factor) do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.to_integer/1)
    |> Stream.map(&(&1 * factor))
    |> Enum.with_index()
  end
end
