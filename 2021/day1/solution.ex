defmodule Solution do
  def part1() do
    input() |> aux()
  end

  def part2() do
    lst = input()
    [_ | lst2] = lst
    [_ | lst3] = lst2

    Enum.zip_with([lst, lst2, lst3], & &1)
    |> Enum.map(&Enum.sum/1)
    |> aux()
  end

  defp aux(lst) do
    [_ | lst2] = lst

    Enum.zip(lst, lst2)
    |> Enum.reduce(0, fn {a, b}, acc ->
      acc + if a < b, do: 1, else: 0
    end)
  end

  defp input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.to_integer/1)
    |> Enum.to_list()
  end
end
