defmodule Solution do
  def part1() do
    {ins, nodes} = input()
    steps("AAA", ins, 0, nodes, 0, &(&1 == "ZZZ"))
  end

  def part2() do
    {ins, nodes} = input()

    nodes
    |> Map.keys()
    |> Enum.filter(&String.ends_with?(&1, "A"))
    |> Enum.map(fn n ->
      steps(n, ins, 0, nodes, 0, &String.ends_with?(&1, "Z"))
    end)
    |> Enum.reduce(fn a, b ->
      g = Integer.gcd(a, b)
      div(a * b, g)
    end)
  end

  def steps(curr, ins, pc, nodes, ct, stop?) do
    if stop?.(curr) do
      ct
    else
      {l, r} = nodes[curr]

      case ins[pc] do
        "L" -> l
        _ -> r
      end
      |> steps(ins, rem(pc + 1, map_size(ins)), nodes, ct + 1, stop?)
    end
  end

  def input() do
    [ins, _ | nodes] =
      File.stream!("./input.txt")
      |> Stream.map(&String.trim/1)
      |> Enum.to_list()

    ins =
      ins
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {c, i}, acc ->
        Map.put(acc, i, c)
      end)

    nodes =
      nodes
      |> Enum.reduce(%{}, fn s, acc ->
        r = ~r/[0-9A-Z]+/
        [[n], [l], [r]] = Regex.scan(r, s)
        Map.put(acc, n, {l, r})
      end)

    {ins, nodes}
  end
end
