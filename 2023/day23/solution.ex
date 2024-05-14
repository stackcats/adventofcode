defmodule Solution do
  def part1() do
    input() |> longest_path()
  end

  def part2() do
    input() |> longest_path(true)
  end

  def longest_path(mp, can_climb? \\ false) do
    start =
      mp
      |> Enum.find(fn {{x, _y}, v} -> x == 0 && v == "." end)
      |> elem(0)

    {row, _col} = mp |> Map.keys() |> Enum.max()

    target =
      mp
      |> Enum.find(fn {{x, _y}, v} -> x == row && v == "." end)
      |> elem(0)

    graph =
      :queue.from_list([start])
      |> build_graph(mp, %MapSet{}, %{}, can_climb?)

    dfs(graph, start, target, %MapSet{}, 0)
  end

  def dfs(_, curr, curr, _, steps), do: steps

  def dfs(graph, curr, target, visited, steps) do
    if MapSet.member?(visited, curr) do
      0
    else
      visited = MapSet.put(visited, curr)

      graph[curr]
      |> Enum.map(fn {next, dist} -> dfs(graph, next, target, visited, steps + dist) end)
      |> Enum.max(fn -> 0 end)
    end
  end

  def build_graph(q, mp, visited, graph, can_climb?) do
    case :queue.out(q) do
      {:empty, _} ->
        graph

      {{_, curr}, q} ->
        if MapSet.member?(visited, curr) do
          build_graph(q, mp, visited, graph, can_climb?)
        else
          visited = MapSet.put(visited, curr)

          neighbours(mp, curr, can_climb?)
          |> Enum.map(fn n -> go(mp, n, curr, 1, can_climb?) end)
          |> Enum.reduce({q, graph}, fn {pos, dist}, {q, graph} ->
            q = :queue.snoc(q, pos)
            graph = Map.update(graph, curr, [{pos, dist}], &[{pos, dist} | &1])
            {q, graph}
          end)
          |> then(fn {q, graph} ->
            build_graph(q, mp, visited, graph, can_climb?)
          end)
        end
    end
  end

  def go(mp, curr, prev, steps, can_climb?) do
    lst = neighbours(mp, curr, can_climb?)

    if length(lst) != 2 do
      {curr, steps}
    else
      next = Enum.find(lst, fn pos -> pos != prev end)
      go(mp, next, curr, steps + 1, can_climb?)
    end
  end

  def neighbours(mp, {x, y} = curr, can_climb?) do
    c = if can_climb?, do: ".", else: mp[curr]

    case c do
      "." -> [{-1, 0}, {1, 0}, {0, -1}, {0, 1}] |> Enum.map(fn {dx, dy} -> {x + dx, y + dy} end)
      ">" -> [{x, y + 1}]
      "<" -> [{x, y - 1}]
      "v" -> [{x + 1, y}]
      "^" -> [{x - 1, y}]
    end
    |> Enum.filter(fn pos -> Map.get(mp, pos, "#") != "#" end)
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
