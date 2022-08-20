defmodule Solution do
  @sugar %{capacity: 3, durability: 0, flavor: 0, texture: -3, calories: 2}
  @sprinkles %{capacity: -3, durability: 3, flavor: 0, texture: 0, calories: 9}
  @candy %{capacity: -1, durability: 0, flavor: 4, texture: 0, calories: 1}
  @chocolate %{capacity: 0, durability: 0, flavor: -2, texture: 2, calories: 8}

  def part1() do
    for i <- 1..100,
        j <- 1..(100 - i),
        k <- 1..(100 - i - j),
        i + j + k <= 100 do
      [:capacity, :durability, :flavor, :texture]
      |> Enum.reduce(1, fn col, acc ->
        acc * total(col, i, j, k, 100 - i - j - k)
      end)
    end
    |> Enum.max()
  end

  def part2() do
    for i <- 1..100,
        j <- 1..(100 - i),
        k <- 1..(100 - i - j),
        i + j + k <= 100 do
      score =
        [:capacity, :durability, :flavor, :texture]
        |> Enum.reduce(1, fn col, acc ->
          acc * total(col, i, j, k, 100 - i - j - k)
        end)

      calories = total(:calories, i, j, k, 100 - i - j - k)
      {score, calories}
    end
    |> Enum.filter(fn {_, calories} -> calories == 500 end)
    |> Enum.max_by(fn {score, _} -> score end)
    |> elem(0)
  end

  def total(col, i, j, k, m) do
    (@sugar[col] * i + @sprinkles[col] * j + @candy[col] * k + @chocolate[col] * m)
    |> max(0)
  end
end
