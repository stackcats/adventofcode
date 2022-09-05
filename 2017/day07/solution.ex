defmodule Solution do
  def part1() do
    input()
    |> build_tower()
    |> root()
  end

  def part2() do
    tower = input() |> build_tower()
    r = root(tower)
    aux(tower, r)
  end

  def aux(tower, r) do
    {_weight, xs} = tower[r]

    if xs == [] do
      nil
    else
      unbalanced =
        xs
        |> Enum.reduce_while(nil, fn x, _ ->
          unbalanced = aux(tower, x)

          if unbalanced != nil do
            {:halt, unbalanced}
          else
            {:cont, nil}
          end
        end)

      if unbalanced do
        unbalanced
      else
        weights = xs |> Enum.map(&total_weights(tower, &1))
        [a, b] = find_diff_index(weights)

        if a < 0 do
          nil
        else
          {w, _} = tower[Enum.at(xs, a)]
          w - Enum.at(weights, a) + Enum.at(weights, b)
        end
      end
    end
  end

  def find_diff_index(xs) do
    ndx = Enum.find_index(xs, fn x -> x != hd(xs) end)

    if ndx do
      if Enum.count(xs, fn x -> x == hd(xs) end) == 1 do
        [0, ndx]
      else
        [ndx, 0]
      end
    else
      [-1, -1]
    end
  end

  def total_weights(tower, r) do
    {weight, xs} = tower[r]
    xs |> Enum.reduce(weight, fn x, acc -> acc + total_weights(tower, x) end)
  end

  def build_tower(programs) do
    programs
    |> Enum.reduce(%{}, fn {name, v}, acc -> Map.put(acc, name, v) end)
  end

  def root(tower) do
    vs =
      tower
      |> Map.values()
      |> Enum.reduce(MapSet.new(), fn {_weight, xs}, set ->
        xs |> Enum.reduce(set, fn x, set -> MapSet.put(set, x) end)
      end)

    Map.keys(tower)
    |> Enum.find(fn p -> not MapSet.member?(vs, p) end)
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&parse/1)
    |> Enum.reduce(%{}, fn {name, weight, xs}, acc ->
      Map.put(acc, name, {weight, xs})
    end)
  end

  def parse(s) do
    r = ~r/(?<name>[a-z]+) \((?<weight>\d+)\)/
    xs = String.split(s, "->")

    case xs do
      [a] ->
        Regex.named_captures(r, a)
        |> then(fn m ->
          {m["name"], String.to_integer(m["weight"]), []}
        end)

      [a, b] ->
        Regex.named_captures(r, a)
        |> then(fn m ->
          {m["name"], String.to_integer(m["weight"]),
           b |> String.replace(" ", "") |> String.split(",")}
        end)
    end
  end
end
