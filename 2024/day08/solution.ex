defmodule Solution do
  def part1() do
    run(fn sm -> Enum.drop(sm, 1) |> Enum.take(1) end)
  end

  def part2() do
    run(&Enum.to_list/1)
  end

  def run(take) do
    g = input()

    {r, c} = g |> Map.keys() |> Enum.max()

    valid? = fn {x, y} -> x in 0..r and y in 0..c end

    g
    |> Enum.reduce(%{}, fn
      {_, "."}, acc -> acc
      {pos, c}, acc -> Map.update(acc, c, [pos], &[pos | &1])
    end)
    |> Enum.reduce(%MapSet{}, fn {_, xs}, acc -> antinodes(acc, Enum.sort(xs), valid?, take) end)
    |> MapSet.size()
  end

  def antinodes(st, [], _, _), do: st
  def antinodes(st, [_], _, _), do: st

  def antinodes(st, [{x1, y1} | xs], valid?, take) do
    xs
    |> Enum.reduce(st, fn {x2, y2}, acc ->
      dx = abs(x2 - x1)
      dy = abs(y2 - y1)

      dy = if y1 < y2, do: dy, else: -dy

      [
        {{x1, y1}, fn {x, y} -> {x - dx, y - dy} end},
        {{x2, y2}, fn {x, y} -> {x + dx, y + dy} end}
      ]
      |> Enum.map(fn {init, op} ->
        Stream.unfold(init, fn n -> if valid?.(n), do: {n, op.(n)}, else: nil end)
        |> take.()
      end)
      |> Enum.reduce(acc, fn xs, acc -> MapSet.union(acc, MapSet.new(xs)) end)
    end)
    |> antinodes(xs, valid?, take)
  end

  def input() do
    File.read!("./input.txt")
    |> String.trim()
    |> String.split("\n")
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {r, i}, acc ->
      r
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {c, j}, acc ->
        Map.put(acc, {i, j}, c)
      end)
    end)
  end
end
