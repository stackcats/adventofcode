defmodule Solution do
  def part1() do
    input()
    |> Enum.count(&triangle?/1)
  end

  def part2() do
    input()
    |> transpose()
    |> Enum.reduce(0, fn row, acc ->
      row
      |> Enum.chunk_every(3)
      |> Enum.count(&triangle?/1)
      |> then(&(&1 + acc))
    end)
  end

  def triangle?(lst) do
    [a, b, c] = Enum.sort(lst)
    a + b > c
  end

  def transpose(mat) do
    mat
    |> List.zip()
    |> Enum.map(&Tuple.to_list/1)
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.split/1)
    |> Stream.map(fn arr -> Enum.map(arr, &String.to_integer/1) end)
    |> Enum.to_list()
  end
end
