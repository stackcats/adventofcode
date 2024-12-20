defmodule Solution do
  def part1() do
    run(&(&1 == 2))
  end

  def part2() do
    run(&(&1 <= 20))
  end

  def run(f) do
    g = input()
    {start, _} = Enum.find(g, fn {_, v} -> v == "S" end)
    {end_, _} = Enum.find(g, fn {_, v} -> v == "E" end)

    path = :queue.from_list([{start, -1}]) |> bfs(g, %{})

    Stream.unfold(end_, fn
      -1 -> nil
      curr -> {curr, path[curr]}
    end)
    |> Enum.with_index()
    |> find_cheats(0, f)
  end

  def find_cheats([], acc, _f), do: acc

  def find_cheats([{h, i} | tl], acc, f) do
    acc =
      tl
      |> Enum.count(fn {t, j} ->
        dis = distance(h, t)
        f.(dis) and j - i - dis >= 100
      end)
      |> Kernel.+(acc)

    find_cheats(tl, acc, f)
  end

  def distance({x1, y1}, {x2, y2}) do
    abs(x1 - x2) + abs(y1 - y2)
  end

  def bfs(q, g, seen) do
    case :queue.out(q) do
      {:empty, _} ->
        :error

      {{:value, {{x, y} = curr, prev}}, q} ->
        cond do
          g[curr] == "E" ->
            Map.put(seen, curr, prev)

          seen[curr] != nil ->
            bfs(q, g, seen)

          g[curr] == "#" ->
            bfs(q, g, seen)

          true ->
            seen = Map.put(seen, curr, prev)

            [{-1, 0}, {0, 1}, {1, 0}, {0, -1}]
            |> Enum.reduce(q, fn {dx, dy}, q ->
              :queue.in({{x + dx, y + dy}, curr}, q)
            end)
            |> bfs(g, seen)
        end
    end
  end

  def input() do
    File.read!("./input.txt")
    |> String.split("\n", trim: true)
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
