defmodule Solution do
  def part1() do
    {ts, buses} = input()

    f = fn n -> ceil(ts / n) * n - ts end

    buses
    |> Enum.min_by(fn {n, _} -> f.(n) end)
    |> then(fn {n, _} -> n * f.(n) end)
  end

  def part2() do
    {_, buses} = input()
    [{b, _} | bs] = buses

    Enum.reduce(bs, {b, b}, fn {n, i}, {t, b} ->
      t =
        Stream.iterate(t, &(&1 + b))
        |> Stream.drop_while(fn t -> rem(t + i, n) != 0 end)
        |> Enum.take(1)
        |> hd()

      {t, b * n}
    end)
    |> elem(0)
  end

  def input() do
    [ts, buses] = File.read!("input.txt") |> String.trim() |> String.split("\n")

    buses =
      buses
      |> String.split(",")
      |> Enum.with_index()
      |> Enum.reject(fn {x, _} -> x == "x" end)
      |> Enum.map(fn {n, i} -> {String.to_integer(n), i} end)

    {String.to_integer(ts), buses}
  end
end
