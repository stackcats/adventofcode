defmodule Solution do
  def part1() do
    mp = input() |> Map.new()

    mp
    |> Map.keys()
    |> Enum.count(fn b -> b != "shinygold" and find_shinygold(b, mp, %MapSet{}) end)
  end

  def part2() do
    mp = input() |> Map.new()

    Map.get(mp, "shinygold")
    |> Enum.reduce(0, fn {n, b}, acc ->
      n * count_bags(b, mp) + acc
    end)
  end

  def count_bags(bag, mp) do
    Map.get(mp, bag, [])
    |> Enum.reduce(1, fn {n, b}, acc ->
      n * count_bags(b, mp) + acc
    end)
  end

  def find_shinygold("shinygold", _mp, _st), do: true

  def find_shinygold(bag, mp, st) do
    if bag in st do
      false
    else
      st = MapSet.put(st, bag)

      Map.get(mp, bag, [])
      |> Enum.any?(fn {_, b} -> find_shinygold(b, mp, st) end)
    end
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(fn s ->
      [parent, bags] = String.split(s, " contain ")
      [n1, n2 | _] = String.split(parent, " ")
      {n1 <> n2, parse_bags(bags)}
    end)
  end

  def parse_bags("no other bags.\n"), do: []

  def parse_bags(bags) do
    bags
    |> String.split(", ")
    |> Enum.map(fn s ->
      [num, n1, n2 | _] = String.split(s, " ")
      {String.to_integer(num), n1 <> n2}
    end)
  end
end
