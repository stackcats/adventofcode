defmodule Solution do
  def part1() do
    run() |> elem(0)
  end

  def part2() do
    run() |> elem(1) |> Kernel.+(1)
  end

  def run() do
    g = input()
    {start, _} = Enum.find(g, fn {_, v} -> v == "S" end)

    :queue.from_list([{start, {0, 1}, 0, %MapSet{}}])
    |> bfs(g, %{}, -1, %MapSet{})
  end

  def bfs(q, g, seen, best, tiles) do
    case :queue.out(q) do
      {:empty, _} ->
        {best, MapSet.size(tiles)}

      {{_, {{x, y} = pos, {dx, dy} = dir, score, ts}}, q} ->
        cond do
          Map.get(seen, {pos, dir}, score + 10) < score ->
            bfs(q, g, seen, best, tiles)

          g[pos] == "#" ->
            bfs(q, g, seen, best, tiles)

          g[pos] == "E" ->
            cond do
              best == -1 or best > score -> bfs(q, g, seen, score, ts)
              best < score -> bfs(q, g, seen, best, tiles)
              best == score -> bfs(q, g, seen, best, MapSet.union(tiles, ts))
            end

          true ->
            seen = Map.put(seen, {pos, dir}, score)
            ts = MapSet.put(ts, pos)

            [
              {{x + dx, y + dy}, dir, score + 1, ts},
              {pos, turn_left(dir), score + 1000, ts},
              {pos, turn_right(dir), score + 1000, ts}
            ]
            |> Enum.reduce(q, &:queue.in/2)
            |> bfs(g, seen, best, tiles)
        end
    end
  end

  def turn_left({dx, dy}), do: {dy, -dx}
  def turn_right({dx, dy}), do: {-dy, dx}

  def input() do
    File.read!("./input.txt")
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {s, i}, acc ->
      s
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {c, j}, acc ->
        Map.put(acc, {i, j}, c)
      end)
    end)
  end
end
