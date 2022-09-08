defmodule Solution do
  def part1() do
    input()
    |> run(0, 0)
    |> Enum.sum()
  end

  def part2() do
    input()
    |> aux()
  end

  def aux(lst, i \\ 0) do
    if run(lst, 0, i) |> length() == 0 do
      i
    else
      aux(lst, i + 1)
    end
  end

  def run(lst, i, delay, ans \\ [])
  def run([], _i, _delay, ans), do: ans

  def run([[depth, range] | xs] = lst, i, delay, ans) do
    cond do
      i < depth -> run(lst, i + 1, delay, ans)
      rem(i + delay, range * 2 - 2) == 0 -> run(xs, i + 1, delay, [depth * range | ans])
      true -> run(xs, i + 1, delay, ans)
    end
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.split(&1, ": "))
    |> Stream.map(fn xs ->
      Enum.map(xs, &String.to_integer/1)
    end)
    |> Enum.to_list()
  end
end
