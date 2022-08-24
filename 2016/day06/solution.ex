defmodule Solution do
  def part1() do
    input()
    |> aux(&Enum.max_by/2)
  end

  def part2() do
    input()
    |> aux(&Enum.min_by/2)
  end

  def aux(lst, f) do
    lst
    |> Enum.map(fn row ->
      row
      |> Enum.reduce(%{}, fn c, acc ->
        Map.update(acc, c, 1, &(&1 + 1))
      end)
      |> Enum.to_list()
      |> f.(fn {_, v} -> v end)
      |> elem(0)
    end)
    |> Enum.join()
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.graphemes/1)
    |> Enum.to_list()
    |> transpose()
  end

  def transpose(mat) do
    mat
    |> List.zip()
    |> Enum.map(&Tuple.to_list/1)
  end
end
