defmodule Solution do
  def part1() do
    input() |> loop(80) |> Map.values() |> Enum.sum()
  end

  def part2() do
    input() |> loop(256) |> Map.values() |> Enum.sum()
  end

  def loop(fishes, n) do
    for _ <- 1..n, reduce: fishes do
      acc -> next(acc)
    end
  end

  def next(fishes) do
    Enum.reduce(fishes, %{}, fn {k, v}, acc ->
      cond do
        k == 0 -> acc |> Map.update(6, v, &(&1 + v)) |> Map.update(8, v, &(&1 + v))
        true -> Map.update(acc, k - 1, v, &(&1 + v))
      end
    end)
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.split(&1, ","))
    |> Enum.to_list()
    |> List.first()
    |> Enum.map(&String.to_integer/1)
    |> Enum.reduce(%{}, fn i, acc ->
      Map.update(acc, i, 1, &(&1 + 1))
    end)
  end
end
