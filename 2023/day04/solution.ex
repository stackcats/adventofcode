defmodule Solution do
  def part1() do
    input()
    |> calc_points(0)
    |> Enum.sum()
  end

  def part2() do
    points = input() |> calc_points(2)
    len = length(points)
    mp = 1..len |> Enum.reduce(%{}, fn k, acc -> Map.put(acc, k, 1) end)

    points
    |> Enum.with_index()
    |> Enum.reduce(mp, fn {p, i}, acc ->
      for j <- 1..p//1, i + j < len, reduce: acc do
        acc ->
          Map.update!(acc, i + j + 1, &(&1 + acc[i + 1]))
      end
    end)
    |> Map.values()
    |> Enum.sum()
  end

  def calc_points(cards, ndx) do
    cards
    |> Enum.map(fn [lft, rht] ->
      st = MapSet.new(rht)

      lft
      |> Enum.reduce({0, 1, 0}, fn n, {points, curr_point, ct} ->
        if MapSet.member?(st, n) do
          {curr_point, curr_point * 2, ct + 1}
        else
          {points, curr_point, ct}
        end
      end)
      |> elem(ndx)
    end)
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(fn s ->
      s
      |> String.trim()
      |> String.split(":")
      |> Enum.at(1)
      |> String.split("|")
      |> Enum.map(&to_int/1)
    end)
    |> Enum.to_list()
  end

  def to_int(lst) do
    lst |> String.split(" ") |> Enum.filter(&(&1 != "")) |> Enum.map(&String.to_integer/1)
  end
end
