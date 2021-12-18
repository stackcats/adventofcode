defmodule Solution do
  @template "KHSNHFKVVSVPSCVHBHNP"

  def part1() do
    loop(10)
  end

  def part2() do
    loop(40)
  end

  def loop(n) do
    lst = @template |> String.graphemes()

    pairs =
      [lst, Enum.drop(lst, 1)]
      |> Enum.zip_with(fn [a, b] -> a <> b end)
      |> Enum.reduce(%{}, fn p, acc ->
        Map.update(acc, p, 1, &(&1 + 1))
      end)

    m = input()

    {{_, min}, {_, max}} =
      for _ <- 1..n, reduce: pairs do
        acc -> insert(acc, m)
      end
      |> count()
      |> Enum.min_max_by(fn {_k, v} -> v end)

    max - min
  end

  def insert(pairs, m) do
    Enum.reduce(pairs, %{}, fn {k, v}, acc ->
      a = String.at(k, 0)
      b = String.at(k, 1)
      c = m[k]

      acc
      |> Map.update(a <> c, v, &(&1 + v))
      |> Map.update(c <> b, v, &(&1 + v))
    end)
  end

  def count(pairs) do
    Enum.reduce(pairs, %{}, fn {k, v}, acc ->
      a = String.at(k, 0)
      b = String.at(k, 1)

      acc
      |> Map.update(a, v, &(&1 + v))
      |> Map.update(b, v, &(&1 + v))
    end)
    |> Enum.map(fn {k, v} ->
      if rem(v, 2) == 1 do
        {k, div(v, 2) + 1}
      else
        {k, div(v, 2)}
      end
    end)
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(fn line -> String.replace(line, " ", "") end)
    |> Stream.map(fn line -> String.split(line, "->") end)
    |> Enum.to_list()
    |> Enum.reduce(%{}, fn [k, v], m -> Map.put(m, k, v) end)
  end
end
