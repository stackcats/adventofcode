defmodule Solution do
  defmodule Path do
    defstruct rate: 0, routes: %MapSet{}
  end

  def part1() do
    all_paths(30)
    |> Enum.max_by(fn path -> path.rate end)
    |> Map.get(:rate)
  end

  def part2() do
    paths = all_paths(26)

    for a <- paths, b <- paths, reduce: 0 do
      acc ->
        if a.rate + b.rate > acc && MapSet.intersection(a.routes, b.routes) == %MapSet{} do
          a.rate + b.rate
        else
          acc
        end
    end
  end

  def all_paths(time) do
    {rates, graph} = input()
    dist = floyd_warshall(graph)

    vs =
      rates |> Enum.filter(fn {_, v} -> v != 0 end) |> Enum.map(fn {k, _} -> k end)

    dfs("AA", vs, time, %Path{}, %MapSet{}, dist, rates)
  end

  def floyd_warshall(graph) do
    vs = Map.keys(graph)

    dist =
      for a <- vs, b <- vs, reduce: %{} do
        acc ->
          cond do
            a == b -> 0
            b in graph[a] -> 1
            true -> 99999
          end
          |> then(fn n -> Map.put(acc, {a, b}, n) end)
      end

    for k <- vs, i <- vs, j <- vs, reduce: dist do
      acc ->
        n = min(acc[{i, j}], acc[{i, k}] + acc[{k, j}])
        Map.put(acc, {i, j}, n)
    end
  end

  def dfs(curr, vs, remain_time, path, visited, dist, rates) do
    vs
    |> Enum.reduce([path], fn v, paths ->
      remain_time = remain_time - dist[{curr, v}] - 1

      if remain_time <= 0 || MapSet.member?(visited, v) do
        paths
      else
        rate = path.rate + remain_time * rates[v]
        routes = MapSet.put(path.routes, v)
        path = %{path | rate: rate, routes: routes}
        visited = MapSet.put(visited, v)
        paths ++ dfs(v, vs, remain_time, path, visited, dist, rates)
      end
    end)
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(fn s ->
      [valve | adj] = Regex.scan(~r/[A-Z]{2}/, s) |> Enum.map(&hd/1)
      rate = Regex.scan(~r/\d+/, s) |> hd() |> hd() |> String.to_integer()
      {valve, rate, adj}
    end)
    |> Enum.reduce({%{}, %{}}, fn {k, rate, lst}, {rates, graph} ->
      rates = Map.put(rates, k, rate)
      graph = Map.put(graph, k, lst)
      {rates, graph}
    end)
  end
end
