defmodule Solution do
  @max 10000

  def part1() do
    {edges, nodes} = input()
    nodes |> MapSet.to_list() |> permutations() |> aux(edges, &min/2, @max)
  end

  def part2() do
    {edges, nodes} = input()
    nodes |> MapSet.to_list() |> permutations() |> aux(edges, &max/2, 0)
  end

  def aux([], _edges, _f, ans), do: ans

  def aux([x | xs], edges, f, ans) do
    aux(xs, edges, f, f.(ans, distance(x, edges, 0)))
  end

  def distance([_], _edges, dis), do: dis

  def distance([f, t | xs], edges, dis) do
    distance([t | xs], edges, dis + edges[{f, t}])
  end

  def permutations([]), do: [[]]

  def permutations(list),
    do: for(elem <- list, rest <- permutations(list -- [elem]), do: [elem | rest])

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.split/1)
    |> Enum.to_list()
    |> Enum.reduce({%{}, MapSet.new()}, fn [f, _, t, _, d], {edges, nodes} ->
      d = String.to_integer(d)

      {Map.put(edges, {f, t}, d) |> Map.put({t, f}, d), MapSet.put(nodes, f) |> MapSet.put(t)}
    end)
  end
end
