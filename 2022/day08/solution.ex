defmodule Solution do
  def part1() do
    grid = input()

    MapSet.new()
    |> horizontal(grid)
    |> vertical(grid)
    |> MapSet.size()
  end

  def part2() do
    {g, r, c} = grid = input()

    for i <- 0..(r - 1), j <- 0..(c - 1) do
      [{-1, 0}, {1, 0}, {0, -1}, {0, 1}]
      |> Enum.map(fn {di, dj} ->
        count_tree(grid, {i + di, j + dj}, g[{i, j}], {di, dj})
      end)
      |> Enum.product()
    end
    |> Enum.max()
  end

  def count_tree({g, r, c}, {i, j}, h, {di, dj}) do
    cond do
      i < 0 || j < 0 || i >= r || j >= c -> 0
      g[{i, j}] >= h -> 1
      true -> 1 + count_tree({g, r, c}, {i + di, j + dj}, h, {di, dj})
    end
  end

  def horizontal(set, {g, r, c}) do
    for i <- 0..(r - 1), reduce: set do
      acc ->
        {_, acc} =
          for j <- 0..(c - 1), reduce: {-1, acc} do
            {ma, acc} ->
              h = g[{i, j}]

              if h > ma do
                {h, MapSet.put(acc, {i, j})}
              else
                {ma, acc}
              end
          end

        {_, acc} =
          for j <- (c - 1)..0//-1, reduce: {-1, acc} do
            {ma, acc} ->
              h = g[{i, j}]

              if h > ma do
                {h, MapSet.put(acc, {i, j})}
              else
                {ma, acc}
              end
          end

        acc
    end
  end

  def vertical(set, {g, r, c}) do
    for j <- 0..(c - 1), reduce: set do
      acc ->
        {_, acc} =
          for i <- 0..(r - 1), reduce: {-1, acc} do
            {ma, acc} ->
              h = g[{i, j}]

              if h > ma do
                {h, MapSet.put(acc, {i, j})}
              else
                {ma, acc}
              end
          end

        {_, acc} =
          for i <- (r - 1)..0//-1, reduce: {-1, acc} do
            {ma, acc} ->
              h = g[{i, j}]

              if h > ma do
                {h, MapSet.put(acc, {i, j})}
              else
                {ma, acc}
              end
          end

        acc
    end
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.graphemes/1)
    |> Stream.map(fn lst ->
      lst |> Enum.map(&String.to_integer/1)
    end)
    |> Enum.to_list()
    |> to_map()
  end

  def to_map(lst) do
    r = length(lst)
    c = lst |> hd() |> length()

    g =
      lst
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {row, i}, acc ->
        row
        |> Enum.with_index()
        |> Enum.reduce(acc, fn {c, j}, acc ->
          Map.put(acc, {i, j}, c)
        end)
      end)

    {g, r, c}
  end
end
