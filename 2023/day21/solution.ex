defmodule Solution do
  def part1() do
    {mp, row, col, positions} = prepare()

    1..64
    |> Enum.reduce(positions, fn _, acc ->
      go(acc, mp, row + 1, col + 1)
    end)
    |> MapSet.size()
  end

  def part2() do
    {mp, row, col, positions} = prepare()

    len = row + 1
    x = 26_501_365
    m = rem(x, len)

    targets = MapSet.new([m, m + len, m + len + len])

    1..(m + len + len)
    |> Enum.reduce({[], positions}, fn i, {acc, positions} ->
      positions = go(positions, mp, row + 1, col + 1)

      if MapSet.member?(targets, i) do
        {[MapSet.size(positions) | acc], positions}
      else
        {acc, positions}
      end
    end)
    |> elem(0)
    |> f(div(x, len))
  end

  def prepare() do
    mp = input()
    start = mp |> Enum.find(fn {_, v} -> v == "S" end) |> elem(0)
    mp = Map.put(mp, start, ".")
    {row, col} = mp |> Map.keys() |> Enum.max()
    positions = MapSet.new([start])

    {mp, row, col, positions}
  end

  def f([y2, y1, y0], x) do
    c = y0
    a = (y2 + y0 - 2 * y1) / 2
    b = y1 - y0 - a

    floor(a * x ** 2 + b * x + c)
  end

  def go(positions, mp, row, col) do
    positions
    |> Enum.reduce(%MapSet{}, fn {x, y}, acc ->
      [{-1, 0}, {1, 0}, {0, 1}, {0, -1}]
      |> Enum.reduce(acc, fn {dx, dy}, acc ->
        {nx, ny} = {x + dx, y + dy}

        map_x = rem(row + rem(nx, row), row)
        map_y = rem(col + rem(ny, col), col)

        if mp[{map_x, map_y}] == "." do
          MapSet.put(acc, {nx, ny})
        else
          acc
        end
      end)
    end)
  end

  def input() do
    File.stream!("./input.txt")
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {s, i}, acc ->
      s
      |> String.trim()
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {c, j}, acc ->
        Map.put(acc, {i, j}, c)
      end)
    end)
  end
end
