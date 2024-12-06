defmodule Solution do
  def part1() do
    {rules, update} = input()

    update
    |> Enum.filter(fn xs ->
      check(xs, rules)
    end)
    |> Enum.map(fn xs ->
      Enum.at(xs, div(length(xs), 2))
    end)
    |> Enum.sum()
  end

  def part2() do
    {rules, update} = input()

    update
    |> Enum.reject(&check(&1, rules))
    |> Enum.map(&sort(&1, rules))
    |> Enum.map(fn xs -> Enum.at(xs, div(length(xs), 2)) end)
    |> Enum.sum()
  end

  def sort(xs, rules) do
    Enum.sort(xs, fn a, b ->
      Map.has_key?(rules, a) && b in rules[a]
    end)
  end

  def check([_], _), do: true

  def check([x | xs], rules) do
    Enum.all?(xs, fn y -> before?(x, y, rules) end) and check(xs, rules)
  end

  def before?(x, y, rules) do
    rule = Map.get(rules, x, [])

    cond do
      rule == [] -> false
      y in rule -> true
      # Enum.any?(rule, &before?(&1, y, rules))
      true -> false
    end
  end

  def input() do
    [rules, update] =
      File.read!("./input.txt")
      |> String.split("\n\n")

    rules =
      rules
      |> String.trim()
      |> String.split("\n")
      |> Enum.reduce(%{}, fn s, acc ->
        [a, b] = String.split(s, "|") |> Enum.map(&String.to_integer/1)
        Map.update(acc, a, [b], &[b | &1])
      end)

    update =
      update
      |> String.trim()
      |> String.split("\n")
      |> Enum.map(fn s ->
        s
        |> String.split(",")
        |> Enum.map(&String.to_integer/1)
      end)

    {rules, update}
  end
end
