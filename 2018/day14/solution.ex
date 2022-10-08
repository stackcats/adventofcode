defmodule Solution do
  @input 894_501
  @input_list [1, 0, 5, 4, 9, 8]

  def part1() do
    make_recipes(%{0 => 3, 1 => 7}, 0, 1)
    |> sum(@input..(@input + 9))
  end

  def part2() do
    make_recipes2(%{0 => 3, 1 => 7}, 0, 1, [7, 3])
  end

  def sum(map, range) do
    range
    |> Enum.reduce(0, fn i, acc ->
      acc * 10 + map[i]
    end)
  end

  def make_recipes(recipes, a, b) do
    size = map_size(recipes)

    if size >= @input + 10 do
      recipes
    else
      new_recipe = recipes[a] + recipes[b]

      if new_recipe >= 10 do
        recipes
        |> Map.put(size, div(new_recipe, 10))
        |> Map.put(size + 1, rem(new_recipe, 10))
      else
        recipes |> Map.put(size, new_recipe)
      end
      |> then(fn recipes ->
        size = map_size(recipes)
        make_recipes(recipes, rem(a + recipes[a] + 1, size), rem(b + recipes[b] + 1, size))
      end)
    end
  end

  def make_recipes2(recipes, a, b, lst) do
    size = map_size(recipes)

    cond do
      Enum.take(lst, 6) == @input_list ->
        size - 6

      tl(lst) == @input_list ->
        size - 7

      true ->
        new_recipe = recipes[a] + recipes[b]

        if new_recipe >= 10 do
          recipes
          |> Map.put(size, div(new_recipe, 10))
          |> Map.put(size + 1, rem(new_recipe, 10))
          |> make_recipes2(
            rem(a + recipes[a] + 1, size + 2),
            rem(b + recipes[b] + 1, size + 2),
            [
              rem(new_recipe, 10),
              div(new_recipe, 10) | lst
            ]
            |> Enum.take(7)
          )
        else
          recipes
          |> Map.put(size, new_recipe)
          |> make_recipes2(
            rem(a + recipes[a] + 1, size + 1),
            rem(b + recipes[b] + 1, size + 1),
            [new_recipe | lst] |> Enum.take(7)
          )
        end
    end
  end
end
