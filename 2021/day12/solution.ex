defmodule Solution do
  def part1() do
    edges = input()
    paths("start", edges, MapSet.new(), 0) |> elem(1)
  end

  def part2() do
    edges = input()
    paths2("start", edges, MapSet.new(), nil, 0) |> elem(2)
  end

  def paths(node, edges, visited, ans) do
    cond do
      node == "end" ->
        {visited, ans + 1}

      MapSet.member?(visited, node) ->
        {visited, ans}

      is_uppercase?(node) || node == "start" ->
        Enum.reduce(edges[node], {visited, ans}, fn edge, {visited, acc} ->
          paths(edge, edges, visited, acc)
        end)

      true ->
        visited = MapSet.put(visited, node)

        {visited, ans} =
          Enum.reduce(edges[node], {visited, ans}, fn edge, {visited, acc} ->
            paths(edge, edges, visited, acc)
          end)

        {MapSet.delete(visited, node), ans}
    end
  end

  def paths2(node, edges, visited, special, ans) do
    cond do
      node == "end" ->
        {visited, special, ans + 1}

      is_uppercase?(node) || node == "start" ->
        Enum.reduce(edges[node], {visited, special, ans}, fn edge, {visited, special, acc} ->
          paths2(edge, edges, visited, special, acc)
        end)

      MapSet.member?(visited, node) && special != nil ->
        {visited, special, ans}

      MapSet.member?(visited, node) ->
        {visited, _special, ans} =
          Enum.reduce(edges[node], {visited, node, ans}, fn edge, {visited, special, acc} ->
            paths2(edge, edges, visited, special, acc)
          end)

        {visited, nil, ans}

      true ->
        visited = MapSet.put(visited, node)

        {visited, special, ans} =
          Enum.reduce(edges[node], {visited, special, ans}, fn edge, {visited, special, acc} ->
            paths2(edge, edges, visited, special, acc)
          end)

        {MapSet.delete(visited, node), special, ans}
    end
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(fn line -> String.split(line, "-") end)
    |> Enum.to_list()
    |> Enum.reduce(%{}, fn [a, b], acc ->
      cond do
        a == "start" -> acc |> Map.update(a, [b], &[b | &1])
        a == "end" -> acc |> Map.update(b, [a], &[a | &1])
        b == "start" -> acc |> Map.update(b, [a], &[a | &1])
        b == "end" -> acc |> Map.update(a, [b], &[b | &1])
        true -> acc |> Map.update(a, [b], &[b | &1]) |> Map.update(b, [a], &[a | &1])
      end
    end)
  end

  def is_uppercase?(s) do
    Regex.match?(~r(^[A-Z]*$), s)
  end
end
