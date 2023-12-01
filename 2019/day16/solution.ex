defmodule Solution do
  def part1 do
    lst = input()

    phase(lst, length(lst), 100)
    |> Enum.take(8)
    |> Enum.join()
  end

  def part2() do
    lst = input(10000)
    n = lst |> Enum.take(7) |> Enum.join() |> String.to_integer()

    lst = lst |> Enum.drop(n)

    1..100
    |> Enum.reduce(lst, fn _, acc ->
      acc
      |> Enum.reverse()
      |> Enum.reduce({[], 0}, fn n, {lst, sum} ->
        sum = n + sum
        {[rem(sum, 10) | lst], sum}
      end)
      |> elem(0)
    end)
    |> Enum.take(8)
    |> Enum.join()
  end

  def phase(lst, _, 0), do: lst

  def phase(lst, len, steps) do
    lst
    |> Enum.with_index()
    |> Enum.map(fn {_, i} ->
      pattern =
        [0, 1, 0, -1]
        |> Enum.flat_map(fn n ->
          List.duplicate(n, i + 1)
        end)
        |> Stream.cycle()
        |> Enum.take(len + 1)
        |> Enum.drop(1)

      Enum.zip(lst, pattern)
      |> Enum.reduce(0, fn {n, p}, acc -> acc + n * p end)
      |> abs()
      |> rem(10)
    end)
    |> phase(len, steps - 1)
  end

  def input(times \\ 1) do
    File.stream!("./input.txt")
    |> Enum.to_list()
    |> hd()
    |> String.trim()
    |> String.duplicate(times)
    |> String.to_charlist()
    |> Enum.map(fn c -> c - ?0 end)
  end
end
