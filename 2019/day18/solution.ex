defmodule Solution do
  def part1() do
    run()
  end

  def part2() do
    run(true)
  end

  def run(part2? \\ false) do
    {starts, routes, num_keys} = gen_routes(part2?)

    {0, starts, %MapSet{}}
    |> :gb_sets.add(:gb_sets.new())
    |> find_keys(%{}, routes, num_keys)
  end

  def gen_routes(part2?) do
    g = input()

    {{x, y} = start, _} = g |> Enum.find(fn {_, c} -> c == "@" end)

    starts =
      if part2? do
        [{-1, -1}, {-1, 1}, {1, 1}, {1, -1}]
        |> Enum.map(fn {dx, dy} -> {dx + x, dy + y} end)
      else
        [start]
      end

    g =
      if part2? do
        [{-1, 0}, {0, 1}, {1, 0}, {0, -1}]
        |> Enum.reduce(g, fn {dx, dy}, g ->
          Map.put(g, {dx + x, dy + y}, "#")
        end)
      else
        g
      end

    keys = Enum.filter(g, fn {_k, v} -> v =~ ~r/[a-z]/ end)

    num_keys = length(keys)

    empty_doors = %MapSet{}

    seen = %MapSet{}

    routes =
      for {p1, k1} <- keys do
        for {p2, k2} <- keys, k1 != k2 do
          state = {p1, 0, empty_doors}
          r = bfs(:queue.from_list([state]), g, p2, seen)
          {k2, r}
        end
        |> Map.new()
        |> Map.filter(fn {_k, v} -> v != nil end)
        |> then(fn r -> {k1, r} end)
      end
      |> Map.new()

    routes =
      starts
      |> Enum.reduce(routes, fn p1, routes ->
        state = {p1, 0, empty_doors}

        route =
          keys
          |> Map.new(fn {p2, k} ->
            {k, bfs(:queue.from_list([state]), g, p2, seen)}
          end)
          |> Map.filter(fn {_k, v} -> v != nil end)

        Map.put(routes, p1, route)
      end)

    {starts, routes, num_keys}
  end

  def find_keys(pq, seen, routes, num_keys) do
    if :gb_sets.is_empty(pq) do
      nil
    else
      {{dis, ks, keys}, pq} = :gb_sets.take_smallest(pq)

      cond do
        MapSet.size(keys) == num_keys ->
          dis

        Map.get(seen, {ks, keys}, dis + 10) <= dis ->
          find_keys(pq, seen, routes, num_keys)

        true ->
          seen = Map.put(seen, {ks, keys}, dis)

          ks
          |> Enum.with_index()
          |> Enum.reduce(pq, fn {k, i}, pq ->
            routes[k]
            |> Enum.reduce(pq, fn {nk, {d, doors}}, pq ->
              if MapSet.subset?(doors, keys) do
                ks = List.replace_at(ks, i, nk)
                :gb_sets.add({dis + d, ks, MapSet.put(keys, nk)}, pq)
              else
                pq
              end
            end)
          end)
          |> find_keys(seen, routes, num_keys)
      end
    end
  end

  def bfs(q, g, target, seen) do
    case :queue.out(q) do
      {:empty, _} ->
        nil

      {{:value, {{x, y} = pos, dis, doors}}, q} ->
        cond do
          pos == target ->
            {dis, doors}

          pos in seen ->
            bfs(q, g, target, seen)

          true ->
            seen = MapSet.put(seen, pos)

            [{-1, 0}, {0, 1}, {1, 0}, {0, -1}]
            |> Enum.reduce(q, fn {dx, dy}, q ->
              p = {dx + x, dy + y}
              c = g[p]

              cond do
                c =~ ~r/[a-z.@]/ -> doors
                c =~ ~r/[A-Z]/ -> MapSet.put(doors, String.downcase(c))
                true -> nil
              end
              |> then(fn
                nil -> q
                doors -> :queue.in({p, dis + 1, doors}, q)
              end)
            end)
            |> bfs(g, target, seen)
        end
    end
  end

  def input() do
    File.stream!("input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.with_index()
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
