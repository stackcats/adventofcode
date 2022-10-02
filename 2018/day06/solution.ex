defmodule Solution do
  def part1() do
    coords = input() |> Enum.with_index()

    {bottom, right} =
      coords
      |> Enum.reduce({0, 0}, fn {[x, y], _}, {bottom, right} ->
        {max(x, bottom), max(y, right)}
      end)

    for i <- 0..(bottom + 1), j <- 0..(right + 1), reduce: %{} do
      acc ->
        coords
        |> Enum.map(fn {[x, y], coord} ->
          {abs(i - x) + abs(j - y), coord}
        end)
        |> Enum.sort_by(fn {dis, _} -> dis end)
        |> check_dis()
        |> then(fn coord ->
          Map.update(acc, coord, [{i, j}], &[{i, j} | &1])
        end)
    end
    |> Enum.filter(fn {_, v} ->
      v |> Enum.all?(fn {i, j} -> i > 0 && i <= bottom && j > 0 && j <= right end)
    end)
    |> Enum.map(fn {_, v} -> length(v) end)
    |> Enum.max()
  end

  def part2() do
    coords = input()

    {bottom, right} =
      coords
      |> Enum.reduce({0, 0}, fn [x, y], {bottom, right} ->
        {max(x, bottom), max(y, right)}
      end)

    for i <- 0..(bottom + 1), j <- 0..(right + 1) do
      coords
      |> Enum.reduce(0, fn [x, y], acc ->
        abs(i - x) + abs(j - y) + acc
      end)
    end
    |> Enum.filter(fn x -> x < 10000 end)
    |> Enum.count()
  end

  def check_dis([{d1, a}, {d2, _} | _]) do
    if d1 == d2, do: -1, else: a
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.split(&1, ", "))
    |> Stream.map(fn [y, x] ->
      [String.to_integer(x), String.to_integer(y)]
    end)
    |> Enum.to_list()
  end
end
