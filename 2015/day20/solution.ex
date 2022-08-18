defmodule Solution do
  @target 2_900_000

  def part1() do
    for i <- 1..@target, j <- i..@target//i, reduce: %{} do
      acc -> Map.update(acc, j, i, &(&1 + i))
    end
    |> find_house(10)
  end

  def part2() do
    for i <- 1..@target, j <- i..min(@target, i + i * 50)//i, reduce: %{} do
      acc -> Map.update(acc, j, i, &(&1 + i))
    end
    |> find_house(11)
  end

  def find_house(houses, times) do
    1..@target
    |> Enum.reduce_while(0, fn i, acc ->
      if houses[i] * times >= @target * 10 do
        {:halt, i}
      else
        {:cont, acc}
      end
    end)
  end
end
