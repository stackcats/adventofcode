defmodule Solution do
  @trillion 1_000_000_000_000

  def part1() do
    calc_cost("FUEL", 1, input())
  end

  def part2() do
    bsearch(1, @trillion, input())
  end

  def bsearch(low, high, _) when low >= high, do: low

  def bsearch(low, high, recipes) do
    mid = low + div(high - low, 2)
    cost = calc_cost("FUEL", mid, recipes)

    if cost > @trillion do
      bsearch(low, mid - 1, recipes)
    else
      bsearch(mid, high, recipes)
    end
  end

  def calc_cost(material, amount, recipes) do
    calc_cost(material, amount, recipes, %{}) |> elem(0)
  end

  def calc_cost("ORE", amount, _recipes, inventory), do: {amount, inventory}

  def calc_cost(material, amount, recipes, inventory) do
    {amount, inventory} =
      Map.get_and_update(inventory, material, fn n ->
        cond do
          n == nil -> {amount, 0}
          n >= amount -> {0, n - amount}
          true -> {amount - n, 0}
        end
      end)

    {n, lst} = recipes[material]
    produceRound = ceil(amount / n)
    actualProduced = produceRound * n

    inventory =
      if actualProduced > amount do
        Map.update!(inventory, material, &(&1 + actualProduced - amount))
      else
        inventory
      end

    lst
    |> Enum.reduce({0, inventory}, fn {m, x}, {acc, inventory} ->
      {r, inventory} = calc_cost(x, m * produceRound, recipes, inventory)
      {acc + r, inventory}
    end)
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(fn s ->
      [recipe, output] = s |> String.trim() |> String.split(" => ")

      {n, name} = parse_chemical(output)
      {name, {n, parse_recipe(recipe)}}
    end)
    |> Map.new()
  end

  def parse_recipe(s) do
    s
    |> String.split(", ")
    |> Enum.map(&parse_chemical/1)
  end

  def parse_chemical(s) do
    [n, r] = String.split(s, " ")
    {String.to_integer(n), r}
  end
end
