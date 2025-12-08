defmodule Solution do
  def part1() do
    input()
    |> pair([])
    |> Enum.sort_by(fn {_, d} -> d end)
    |> Enum.take(1000)
    |> Enum.map(&elem(&1, 0))
    |> Enum.reduce(%{}, fn {a, b}, acc -> merge(acc, a, b) end)
    |> groups()
    |> elem(0)
    |> Map.values()
    |> Enum.sort(:desc)
    |> Enum.take(3)
    |> Enum.product()
  end

  def part2() do
    boxes = input()

    rs = Enum.zip(boxes, boxes) |> Map.new()

    boxes
    |> pair([])
    |> Enum.sort_by(fn {_, d} -> d end)
    |> Enum.map(&elem(&1, 0))
    |> Enum.reduce_while(rs, fn {a, b}, acc ->
      {gs, acc} = merge(acc, a, b) |> groups()

      case map_size(gs) do
        1 -> {:halt, {a, b}}
        _ -> {:cont, acc}
      end
    end)
    |> then(fn {[a, _, _], [b, _, _]} -> a * b end)
  end

  def groups(mp) do
    mp
    |> Map.keys()
    |> Enum.reduce({%{}, mp}, fn k, {gs, mp} ->
      {r, mp} = root(mp, k)
      {Map.update(gs, r, 1, &(&1 + 1)), mp}
    end)
  end

  def root(mp, k) do
    case mp[k] do
      nil ->
        {k, Map.put(mp, k, k)}

      ^k ->
        {k, mp}

      r ->
        {v, mp} = root(mp, r)
        {v, Map.put(mp, k, v)}
    end
  end

  def merge(mp, a, b) do
    {ra, mp} = root(mp, a)
    {rb, mp} = root(mp, b)
    Map.put(mp, ra, rb)
  end

  def pair([], ys), do: ys

  def pair([x0 | xs], ys) do
    zs = Enum.map(xs, fn x -> {{x0, x}, dist(x0, x)} end)
    pair(xs, ys ++ zs)
  end

  def dist([x1, y1, z1], [x2, y2, z2]) do
    :math.sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2) + (z1 - z2) * (z1 - z2))
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(fn s ->
      s
      |> String.trim()
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)
    end)
    |> Enum.to_list()
  end
end
