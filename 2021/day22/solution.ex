defmodule Solution do
  def part1() do
    rng = -50..50

    input()
    |> Enum.filter(fn {_, coords} ->
      Enum.all?(coords, fn r -> r.first in rng and r.last in rng end)
    end)
    |> run()
  end

  def part2() do
    input() |> run()
  end

  def volume({on, coords}) do
    a = if on, do: 1, else: -1
    v = Enum.map(coords, fn r -> r.last - r.first + 1 end) |> Enum.product()
    a * v
  end

  def run(cubes) do
    cubes
    |> Enum.reduce([], fn cube, acc ->
      acc
      |> Enum.flat_map(fn c ->
        if overlap?(c, cube), do: [overlap(c, cube)], else: []
      end)
      |> Enum.concat(acc)
      |> then(fn acc ->
        if elem(cube, 0), do: [cube | acc], else: acc
      end)
    end)
    |> Enum.map(&volume/1)
    |> Enum.sum()
  end

  def overlap?({_, c1}, {_, c2}) do
    Enum.zip(c1, c2) |> Enum.all?(fn {a, b} -> overlap?(a, b) end)
  end

  def overlap?(r1, r2) do
    r1.first <= r2.last and r1.last >= r2.first
  end

  def overlap({on, c1}, {_, c2}) do
    {not on, Enum.zip(c1, c2) |> Enum.map(fn {a, b} -> overlap(a, b) end)}
  end

  def overlap(r1, r2) do
    max(r1.first, r2.first)..min(r1.last, r2.last)
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(fn s ->
      on = String.starts_with?(s, "on")

      Regex.scan(~r/-?\d+/, s)
      |> Enum.map(fn each -> hd(each) |> String.to_integer() end)
      |> then(fn [x1, x2, y1, y2, z1, z2] ->
        {on, [x1..x2, y1..y2, z1..z2]}
      end)
    end)
    |> Enum.to_list()
  end
end
