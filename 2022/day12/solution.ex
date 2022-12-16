defmodule Solution do
  def part1() do
    g = input()

    g
    |> Enum.find(fn {_, c} -> c == ?S end)
    |> elem(0)
    |> shortest_path(g)
  end

  def part2() do
    g = input()

    g
    |> Enum.filter(fn {_, c} -> c in [?S, ?a] end)
    |> Enum.map(&elem(&1, 0))
    |> Enum.map(&shortest_path(&1, g))
    |> Enum.min()
  end

  def shortest_path(s, g) do
    :queue.from_list([{s, 0}]) |> bfs(g)
  end

  def bfs(q, g) do
    if :queue.is_empty(q) do
      500
    else
      {{x, y} = pos, ct} = :queue.head(q)
      q = :queue.drop(q)
      c = g[pos]

      case c do
        ?E ->
          ct

        ?. ->
          bfs(q, g)

        _ ->
          [{-1, 0}, {1, 0}, {0, 1}, {0, -1}]
          |> Enum.reduce(q, fn {dx, dy}, q ->
            next_pos = {x + dx, y + dy}

            if can_move(c, g[next_pos]), do: :queue.in({next_pos, ct + 1}, q), else: q
          end)
          |> bfs(Map.put(g, pos, ?.))
      end
    end
  end

  def can_move(c, nc) do
    c = if c == ?S, do: ?a, else: c
    nc = if nc == ?E, do: ?z, else: nc
    c + 1 >= nc
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.to_charlist/1)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {row, i}, acc ->
      row
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {c, j}, acc ->
        Map.put(acc, {i, j}, c)
      end)
    end)
  end
end
