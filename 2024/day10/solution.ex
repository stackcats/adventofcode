defmodule Solution do
  def part1() do
    run(0)
  end

  def part2() do
    run(1)
  end

  def run(i) do
    g = input()

    g
    |> Enum.filter(fn {_, c} -> c == 0 end)
    |> Enum.reduce({0, 0}, fn {pos, _}, {scores, ratings} ->
      {trailheads, rating} =
        [pos]
        |> :queue.from_list()
        |> bfs(g, %MapSet{}, 0)

      {scores + MapSet.size(trailheads), ratings + rating}
    end)
    |> elem(i)
  end

  def bfs(q, g, trailheads, rating) do
    case :queue.out(q) do
      {:empty, _} ->
        {trailheads, rating}

      {{_, {x, y} = curr}, q} ->
        case g[curr] do
          9 ->
            bfs(q, g, MapSet.put(trailheads, curr), rating + 1)

          n ->
            [{-1, 0}, {0, 1}, {1, 0}, {0, -1}]
            |> Enum.reduce(q, fn {dx, dy}, q ->
              next = {x + dx, y + dy}
              if g[next] == n + 1, do: :queue.in(next, q), else: q
            end)
            |> bfs(g, trailheads, rating)
        end
    end
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
        Map.put(acc, {i, j}, String.to_integer(c))
      end)
    end)
  end
end
