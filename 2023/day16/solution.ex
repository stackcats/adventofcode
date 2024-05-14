defmodule Solution do
  def part1() do
    tiles({{0, 0}, {0, 1}}, input())
  end

  def part2() do
    mp = input()
    {row, col} = mp |> Map.keys() |> Enum.max()
    top = for i <- 0..col, do: {{0, i}, {1, 0}}
    bottom = for i <- 0..col, do: {{row, i}, {-1, 0}}
    left = for i <- 0..row, do: {{i, 0}, {0, 1}}
    right = for i <- 0..row, do: {{i, col}, {0, -1}}

    (top ++ bottom ++ left ++ right)
    |> Enum.map(&tiles(&1, mp))
    |> Enum.max()
  end

  def tiles(pos, mp) do
    q = :queue.from_list([pos])
    visited = %MapSet{}

    bfs(q, visited, mp)
    |> Enum.map(fn {pos, _} -> pos end)
    |> MapSet.new()
    |> MapSet.size()
  end

  def bfs(q, visited, mp) do
    case :queue.out(q) do
      {:empty, _} ->
        visited

      {{_, {pos, d}}, q} ->
        cond do
          mp[pos] == nil ->
            bfs(q, visited, mp)

          MapSet.member?(visited, {pos, d}) ->
            bfs(q, visited, mp)

          true ->
            visited = MapSet.put(visited, {pos, d})

            next(pos, d, mp)
            |> Enum.reduce(q, &:queue.in/2)
            |> bfs(visited, mp)
        end
    end
  end

  def next({x, y}, {dx, dy}, mp) do
    case {dx, dy, mp[{x, y}]} do
      # right
      {0, 1, "|"} -> [{-1, 0}, {1, 0}]
      {0, 1, "/"} -> [{-1, 0}]
      {0, 1, "\\"} -> [{1, 0}]
      # left
      {0, -1, "|"} -> [{-1, 0}, {1, 0}]
      {0, -1, "/"} -> [{1, 0}]
      {0, -1, "\\"} -> [{-1, 0}]
      # up
      {-1, 0, "-"} -> [{0, -1}, {0, 1}]
      {-1, 0, "/"} -> [{0, 1}]
      {-1, 0, "\\"} -> [{0, -1}]
      # down
      {1, 0, "-"} -> [{0, 1}, {0, -1}]
      {1, 0, "/"} -> [{0, -1}]
      {1, 0, "\\"} -> [{0, 1}]
      _ -> [{dx, dy}]
    end
    |> Enum.map(fn {dx, dy} -> {{x + dx, y + dy}, {dx, dy}} end)
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.graphemes/1)
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
