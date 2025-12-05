defmodule Solution do
  def part1() do
    {rng, ids} = input()

    Enum.count(ids, fn id ->
      Enum.any?(rng, fn [f, t] -> id >= f and id <= t end)
    end)
  end

  def part2() do
    input()
    |> elem(0)
    |> Enum.sort()
    |> merge([])
    |> Enum.reduce(0, fn [f, t], acc ->
      acc + t - f + 1
    end)
  end

  def merge([x | xs], []), do: merge(xs, [x])
  def merge([], merged), do: merged

  def merge([[f1, t1] = x | xs], [[f2, t2] = y | ys]) do
    if f1 > t2 do
      merge(xs, [x, y | ys])
    else
      merge(xs, [[f2, max(t1, t2)] | ys])
    end
  end

  def input() do
    [rng, ids] =
      File.read!("./input.txt")
      |> String.split("\n\n", trim: true)

    rng =
      String.split(rng, "\n", trim: true)
      |> Enum.map(fn x ->
        Regex.run(~r/(\d+)-(\d+)/, x)
        |> tl()
        |> Enum.map(&String.to_integer/1)
      end)

    ids =
      String.split(ids, "\n", trim: true)
      |> Enum.map(&String.to_integer/1)

    {rng, ids}
  end
end
