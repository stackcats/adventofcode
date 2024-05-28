defmodule Solution do
  def part1() do
    {g, start, finish, portals} = maze()

    bfs(:gb_sets.from_list([{0, start, 0}]), %{}, g, portals, finish, fn _, _ -> 0 end)
  end

  def part2() do
    {g, start, finish, portals} = maze()
    {{row, col}, _} = g |> Enum.max_by(fn {k, _} -> k end)

    update_level = fn {x, y}, level ->
      if x in [2, row - 2] or y in [2, col - 2] do
        if level <= 0, do: nil, else: level - 1
      else
        level + 1
      end
    end

    bfs(:gb_sets.from_list([{0, start, 0}]), %{}, g, portals, finish, update_level)
  end

  def maze() do
    g = input()
    portals = find_portals(g)
    {start, _} = portals |> Enum.find(fn {_, v} -> v == "AA" end)
    {finish, _} = portals |> Enum.find(fn {_, v} -> v == "ZZ" end)

    pairs =
      portals
      |> Enum.reduce(%{}, fn {p, portal}, acc ->
        case portals |> Enum.find(fn {q, target} -> portal == target and p != q end) do
          nil -> acc
          {q, _} -> Map.put(acc, p, q)
        end
      end)

    {g, start, finish, pairs}
  end

  def bfs(q, seen, g, portals, target, update_level) do
    {{ct, {x, y} = pos, level}, q} = :gb_sets.take_smallest(q)

    cond do
      pos == target and level == 0 ->
        ct

      pos == target ->
        bfs(q, seen, g, portals, target, update_level)

      Map.get(seen, {pos, level}, ct + 10) <= ct ->
        bfs(q, seen, g, portals, target, update_level)

      true ->
        seen = Map.put(seen, {pos, level}, ct)

        [{-1, 0}, {0, 1}, {1, 0}, {0, -1}]
        |> Enum.reduce(q, fn {dx, dy}, acc ->
          pos = {x + dx, y + dy}

          cond do
            g[pos] != "." ->
              acc

            portals[pos] != nil ->
              case update_level.(pos, level) do
                nil -> acc
                level -> :gb_sets.add({ct + 2, portals[pos], level}, acc)
              end

            true ->
              :gb_sets.add({ct + 1, pos, level}, acc)
          end
        end)
        |> bfs(seen, g, portals, target, update_level)
    end
  end

  def find_portals(g) do
    label = ~r/[A-Z]/

    g
    |> Enum.flat_map(fn
      {{x, y} = pos, "."} ->
        [{{-2, 0}, {-1, 0}}, {{0, 1}, {0, 2}}, {{1, 0}, {2, 0}}, {{0, -2}, {0, -1}}]
        |> Enum.find(fn {{x1, y1}, {x2, y2}} ->
          g[{x + x1, y + y1}] =~ label and g[{x + x2, y + y2}] =~ label
        end)
        |> then(fn
          nil -> []
          {{x1, y1}, {x2, y2}} -> [{pos, g[{x + x1, y + y1}] <> g[{x + x2, y + y2}]}]
        end)

      _ ->
        []
    end)
    |> Map.new()
  end

  def input() do
    File.read!("./input.txt")
    |> String.split("\n")
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
