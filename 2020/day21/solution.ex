defmodule Solution do
  def part1() do
    mp = input()
    ingredients = mp |> Map.keys() |> Enum.reduce(&MapSet.union/2)
    allergens = mp |> Map.values() |> Enum.reduce(&MapSet.union/2)

    allergens
    |> Enum.map(fn allergen ->
      mp
      |> Enum.flat_map(fn {k, v} -> if allergen in v, do: [k], else: [] end)
      |> Enum.reduce(&MapSet.intersection/2)
    end)
    |> Enum.reduce(&MapSet.union/2)
    |> then(fn st -> MapSet.difference(ingredients, st) end)
    |> then(fn targets ->
      mp
      |> Enum.map(fn {k, _} -> MapSet.intersection(targets, k) |> MapSet.size() end)
      |> Enum.sum()
    end)
  end

  def part2() do
    mp = input()

    mp
    |> Map.values()
    |> Enum.reduce(&MapSet.union/2)
    |> Map.new(fn allergen ->
      candidates =
        mp
        |> Enum.flat_map(fn {k, v} -> if allergen in v, do: [k], else: [] end)
        |> Enum.reduce(&MapSet.intersection/2)

      {allergen, candidates}
    end)
    |> run(%{})
    |> Enum.sort_by(&elem(&1, 0))
    |> Enum.map(&elem(&1, 1))
    |> Enum.join(",")
  end

  def run(mp, res) when map_size(mp) == 0, do: res

  def run(mp, res) do
    {matched, mp} = mp |> Map.split_with(fn {_, v} -> MapSet.size(v) == 1 end)

    matched = matched |> Map.new(fn {k, v} -> {k, MapSet.to_list(v) |> hd()} end)

    res = Map.merge(res, matched)

    matched
    |> Enum.reduce(mp, fn {_, v}, acc ->
      acc
      |> Map.new(fn {k, vs} -> {k, MapSet.delete(vs, v)} end)
    end)
    |> run(res)
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Map.new(fn s ->
      [ingredients, allergens] = String.split(s, " (contains ")
      ingredients = ingredients |> String.split(" ") |> MapSet.new()
      allergens = allergens |> String.trim(")") |> String.split(", ") |> MapSet.new()
      {ingredients, allergens}
    end)
  end
end
