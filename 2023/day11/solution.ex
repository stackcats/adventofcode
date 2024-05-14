defmodule Solution do
  def part1() do
    input() |> all_distance()
  end

  def part2() do
    input() |> all_distance(1_000_000)
  end

  def all_distance(mp, expanded_factor \\ 2) do
    {row, col} = get_border(mp)
    rows = expand_rows(mp, row, col)
    cols = expand_cols(mp, row, col)
    galaxies = find_galaxies(mp)

    for x <- galaxies, y <- galaxies, x != y, reduce: 0 do
      acc ->
        acc + distance(x, y, rows, cols, expanded_factor)
    end
    |> div(2)
  end

  def distance({x1, y1}, {x2, y2}, rows, cols, expanded_factor) do
    v = offset(x1, x2, rows, expanded_factor) - 1
    h = offset(y1, y2, cols, expanded_factor) - 1
    v + h
  end

  def offset(a, b, st, expanded_factor) do
    for x <- a..b, reduce: 0 do
      acc ->
        acc + if MapSet.member?(st, x), do: expanded_factor, else: 1
    end
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.graphemes/1)
    |> to_map()
  end

  def to_map(lst) do
    lst
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {row, i}, acc ->
      row
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {c, j}, acc ->
        Map.put(acc, {i, j}, c)
      end)
    end)
  end

  def find_galaxies(mp) do
    mp
    |> Map.keys()
    |> Enum.filter(fn k -> mp[k] == "#" end)
  end

  def get_border(mp) do
    mp
    |> Map.keys()
    |> Enum.max()
  end

  def expand_rows(mp, row, col) do
    0..row
    |> Enum.reduce([], fn i, acc ->
      if Enum.all?(0..col, fn j -> mp[{i, j}] == "." end) do
        [i | acc]
      else
        acc
      end
    end)
    |> MapSet.new()
  end

  def expand_cols(mp, row, col) do
    0..col
    |> Enum.reduce([], fn j, acc ->
      if Enum.all?(0..row, fn i -> mp[{i, j}] == "." end) do
        [j | acc]
      else
        acc
      end
    end)
    |> MapSet.new()
  end
end
