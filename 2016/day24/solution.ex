defmodule Solution do
  def part1() do
    aux(fn p -> ["0" | p] end)
  end

  def part2() do
    aux(fn p -> ["0" | p] ++ ["0"] end)
  end

  def aux(route_fn) do
    {grid, points} = input()

    paths = calc_paths(grid, points)

    points
    |> Map.keys()
    |> List.delete("0")
    |> permutations()
    |> Enum.map(route_fn)
    |> Enum.map(&total_distance(&1, paths))
    |> Enum.min()
  end

  def calc_paths(grid, points) do
    last_point = points |> Map.keys() |> Enum.max() |> String.to_integer()

    for i <- 0..(last_point - 1), j <- (i + 1)..last_point, reduce: %{} do
      acc ->
        i = "#{i}"
        j = "#{j}"

        ct =
          :queue.new()
          |> :queue.snoc({points[i], 0})
          |> bfs(points[j], MapSet.new(), grid)

        acc |> Map.put({i, j}, ct) |> Map.put({j, i}, ct)
    end
  end

  def bfs(q, target, visited, grid) do
    {pos, ct} = :queue.head(q)
    q = :queue.tail(q)

    cond do
      pos == target ->
        ct

      MapSet.member?(visited, pos) ->
        bfs(q, target, visited, grid)

      true ->
        pos
        |> neighbors(ct, grid)
        |> Enum.reduce(q, &:queue.in/2)
        |> bfs(target, MapSet.put(visited, pos), grid)
    end
  end

  def neighbors({x, y}, ct, grid) do
    [{-1, 0}, {0, 1}, {1, 0}, {0, -1}]
    |> Enum.filter(fn {dx, dy} ->
      grid[{dx + x, dy + y}] != nil && grid[{dx + x, dy + y}] != "#"
    end)
    |> Enum.map(fn {dx, dy} -> {{x + dx, y + dy}, ct + 1} end)
  end

  def permutations([]), do: [[]]

  def permutations(list),
    do: for(elem <- list, rest <- permutations(list -- [elem]), do: [elem | rest])

  def total_distance(xs, paths), do: total_distance(xs, paths, 0)
  def total_distance([_], _paths, dis), do: dis

  def total_distance([x, y | xs], paths, dis) do
    total_distance([y | xs], paths, dis + paths[{x, y}])
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.graphemes/1)
    |> Enum.to_list()
    |> Enum.with_index()
    |> Enum.reduce({%{}, %{}}, fn {row, i}, {grid, pos} ->
      row
      |> Enum.with_index()
      |> Enum.reduce({grid, pos}, fn {c, j}, {grid, pos} ->
        pos =
          if Regex.match?(~r/\d/, c) do
            Map.put(pos, c, {i, j})
          else
            pos
          end

        {Map.put(grid, {i, j}, c), pos}
      end)
    end)
  end
end
