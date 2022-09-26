defmodule Solution do
  def part1() do
    requirements = input()

    nodes =
      requirements
      |> Enum.reduce(MapSet.new(), fn {x, y}, nodes ->
        nodes |> MapSet.put(x) |> MapSet.put(y)
      end)

    {ins, outs} =
      nodes
      |> Enum.reduce({%{}, %{}}, fn n, {ins, outs} ->
        {Map.put(ins, n, 0), Map.put(outs, n, [])}
      end)

    {ins, outs} =
      requirements
      |> Enum.reduce({ins, outs}, fn {x, y}, {ins, outs} ->
        {Map.update!(ins, y, &(&1 + 1)), Map.update!(outs, x, &[y | &1])}
      end)

    aux(ins, outs)
  end

  def aux(ins, outs, s \\ "") do
    if map_size(ins) == 0 do
      s
    else
      {node, _} = ins |> Enum.min_by(fn {k, v} -> {v, k} end)

      ins = Map.delete(ins, node)

      outs[node]
      |> Enum.reduce(ins, fn n, ins ->
        Map.update!(ins, n, &(&1 - 1))
      end)
      |> aux(outs, s <> node)
    end
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(fn s ->
      ~r/Step (?<x>[A-Z]) must be finished before step (?<y>[A-Z]) can begin./
      |> Regex.named_captures(s)
      |> then(fn m ->
        {m["x"], m["y"]}
      end)
    end)
    |> Enum.to_list()
  end
end
