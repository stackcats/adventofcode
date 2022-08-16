defmodule Solution do
  def part1() do
    {edges, nodes} = input()

    nodes
    |> MapSet.to_list()
    |> permutations()
    |> aux(edges)
  end

  def part2() do
    {edges, nodes} = input()

    edges =
      nodes
      |> Enum.reduce(edges, fn n, edges ->
        edges |> Map.put({"host", n}, 0) |> Map.put({n, "host"}, 0)
      end)

    nodes
    |> MapSet.put("host")
    |> MapSet.to_list()
    |> permutations()
    |> aux(edges)
  end

  def aux(perms, edges) do
    perms
    |> Enum.reduce(0, fn p, acc ->
      max(acc, happiness(p, edges))
    end)
  end

  def happiness(ns, edges) do
    happiness(ns ++ [hd(ns)], edges, 0)
  end

  def happiness([_], _edges, ans) do
    ans
  end

  def happiness([a, b | ns], edges, ans) do
    ans = ans + edges[{a, b}] + edges[{b, a}]
    happiness([b | ns], edges, ans)
  end

  def permutations([]), do: [[]]

  def permutations(list),
    do: for(elem <- list, rest <- permutations(list -- [elem]), do: [elem | rest])

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.split/1)
    |> Stream.map(fn [a, _, type, v, _, _, _, _, _, _, b] ->
      b = String.replace_trailing(b, ".", "")
      sign = if type == "gain", do: 1, else: -1
      {a, b, String.to_integer(v) * sign}
    end)
    |> Enum.to_list()
    |> Enum.reduce({%{}, MapSet.new()}, fn {a, b, v}, {edges, nodes} ->
      {
        edges |> Map.put({a, b}, v),
        nodes |> MapSet.put(a) |> MapSet.put(b)
      }
    end)
  end
end
