defmodule Solution do
  use Bitwise

  @key "xlqgujun"

  def part1() do
    gen_grid()
    |> Map.values()
    |> Enum.count(fn c -> c == "1" end)
  end

  def part2() do
    grid = gen_grid()

    for i <- 0..127, j <- 0..127, reduce: {0, grid} do
      {regions, grid} ->
        if grid[{i, j}] == "1" do
          {regions + 1, dfs(grid, i, j)}
        else
          {regions, grid}
        end
    end
    |> elem(0)
  end

  def dfs(grid, i, j) do
    if grid[{i, j}] != "1" do
      grid
    else
      grid = Map.put(grid, {i, j}, "0")

      [{-1, 0}, {0, 1}, {1, 0}, {0, -1}]
      |> Enum.reduce(grid, fn {dx, dy}, grid ->
        dfs(grid, i + dx, j + dy)
      end)
    end
  end

  def gen_grid() do
    for i <- 0..127 do
      "#{@key}-#{i}"
      |> knot_hash()
      |> String.graphemes()
    end
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {row, i}, acc ->
      row
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {c, j}, acc ->
        Map.put(acc, {i, j}, c)
      end)
    end)
  end

  def knot_hash(s) do
    s
    |> String.graphemes()
    |> Enum.map(&:binary.first/1)
    |> knot()
  end

  def knot(lst, rounds \\ 64) do
    m =
      0..255
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {n, i}, acc ->
        Map.put(acc, i, n)
      end)

    for _ <- 1..rounds, reduce: {m, 0, 0} do
      {m, pos, skip} -> hash(m, lst ++ [17, 31, 73, 47, 23], pos, skip)
    end
    |> elem(0)
    |> then(fn m ->
      for i <- 0..255//16 do
        for j <- i..(i + 15) do
          m[j]
        end
        |> Enum.reduce(&bxor/2)
        |> to_bin()
      end
      |> Enum.join()
    end)
  end

  def hash(m, [], pos, skip), do: {m, pos, skip}

  def hash(m, [x | xs], pos, skip) do
    m = reverse(m, pos, x - 1)
    hash(m, xs, rem(pos + x + skip, map_size(m)), skip + 1)
  end

  def reverse(m, _x, len) when len <= 0, do: m

  def reverse(m, x, len) do
    y = rem(x + len, map_size(m))

    m
    |> Map.put(x, m[y])
    |> Map.put(y, m[x])
    |> reverse(rem(x + 1, map_size(m)), len - 2)
  end

  def to_bin(n) do
    n |> Integer.to_string(2) |> String.pad_leading(8, "0")
  end
end
