defmodule Solution do
  def part1() do
    g = input()

    g
    |> Enum.reduce(%MapSet{}, fn {k, vs}, acc ->
      for a <- vs, b <- vs, a != b, reduce: acc do
        acc ->
          if a in g[b] do
            MapSet.put(acc, Enum.sort([k, a, b]))
          else
            acc
          end
      end
    end)
    |> Enum.count(fn set ->
      Enum.find(set, &String.starts_with?(&1, "t"))
    end)
  end

  def part2() do
    g = input()

    g
    |> Enum.reduce(%MapSet{}, fn {k, vs}, acc ->
      clique =
        vs
        |> Enum.map(fn v ->
          vs
          |> MapSet.delete(v)
          |> Enum.reduce(MapSet.new([k, v]), fn w, acc ->
            if Enum.any?(acc, fn v -> w not in g[v] end) do
              acc
            else
              MapSet.put(acc, w)
            end
          end)
        end)
        |> Enum.max_by(&MapSet.size/1)

      if MapSet.size(clique) > MapSet.size(acc) do
        clique
      else
        acc
      end
    end)
    |> Enum.sort()
    |> Enum.join(",")
  end

  def input() do
    File.read!("./input.txt")
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, "-"))
    |> Enum.reduce(%{}, fn [f, t], acc ->
      acc
      |> Map.update(f, MapSet.new([t]), &MapSet.put(&1, t))
      |> Map.update(t, MapSet.new([f]), &MapSet.put(&1, f))
    end)
  end
end
