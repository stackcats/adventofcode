defmodule Solution do
  def part1() do
    mp = %{"X" => "A", "Y" => "B", "Z" => "C"}

    input()
    |> Enum.reduce(0, fn [a, b], acc ->
      score =
        case [a, mp[b]] do
          ["A", "A"] -> 1 + 3
          ["A", "B"] -> 2 + 6
          ["A", "C"] -> 3 + 0
          ["B", "A"] -> 1 + 0
          ["B", "B"] -> 2 + 3
          ["B", "C"] -> 3 + 6
          ["C", "A"] -> 1 + 6
          ["C", "B"] -> 2 + 0
          ["C", "C"] -> 3 + 3
        end

      acc + score
    end)
  end

  def part2() do
    input()
    |> Enum.reduce(0, fn [a, b], acc ->
      score =
        case [a, b] do
          ["A", "X"] -> 0 + 3
          ["A", "Y"] -> 3 + 1
          ["A", "Z"] -> 6 + 2
          ["B", "X"] -> 0 + 1
          ["B", "Y"] -> 3 + 2
          ["B", "Z"] -> 6 + 3
          ["C", "X"] -> 0 + 2
          ["C", "Y"] -> 3 + 3
          ["C", "Z"] -> 6 + 1
        end

      acc + score
    end)
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.split(&1, " "))
    |> Enum.to_list()
  end
end
