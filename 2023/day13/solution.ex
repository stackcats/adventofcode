defmodule Solution do
  def part1() do
    input() |> aux()
  end

  def part2() do
    input() |> aux(1)
  end

  def aux(lst, diff \\ 0) do
    lst
    |> Enum.reduce(0, fn {mat, trans}, acc ->
      acc +
        case find_horizontal(mat, diff) do
          nil -> find_horizontal(trans, diff)
          n -> n * 100
        end
    end)
  end

  def find_horizontal(mat, diff) do
    1..(length(mat) - 1)
    |> Enum.find(fn i ->
      {above, below} = Enum.split(mat, i)

      above
      |> Enum.reverse()
      |> Enum.zip(below)
      |> Enum.reduce(0, fn {la, lb}, acc ->
        Enum.zip(la, lb)
        |> Enum.count(fn {a, b} -> a != b end)
        |> then(&(&1 + acc))
      end)
      |> then(&(&1 == diff))
    end)
  end

  def input() do
    File.read!("./input.txt")
    |> String.trim()
    |> String.split("\n\n")
    |> Enum.map(fn s ->
      mat =
        s
        |> String.split("\n")
        |> Enum.map(&String.graphemes/1)

      trans =
        mat
        |> List.zip()
        |> Enum.map(&Tuple.to_list/1)

      {mat, trans}
    end)
  end
end
