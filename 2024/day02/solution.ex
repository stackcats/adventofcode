defmodule Solution do
  def part1() do
    input() |> Enum.count(&safe?/1)
  end

  def part2() do
    input()
    |> Enum.count(fn xs ->
      0..(length(xs) - 1)
      |> Enum.any?(fn i -> List.delete_at(xs, i) |> safe?() end)
    end)
  end

  def safe?(xs) do
    asc?(xs) or desc?(xs)
  end

  def asc?(xs) do
    Enum.zip(xs, tl(xs))
    |> Enum.all?(fn {a, b} -> (a - b) in -1..-3 end)
  end

  def desc?(xs) do
    Enum.zip(xs, tl(xs))
    |> Enum.all?(fn {a, b} -> (a - b) in 1..3 end)
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(fn s ->
      s
      |> String.trim()
      |> String.split(" ")
      |> Enum.map(&String.to_integer/1)
    end)
  end
end
