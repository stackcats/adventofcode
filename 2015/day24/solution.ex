defmodule Solution do
  def part1() do
    input() |> aux(3)
  end

  def part2() do
    input() |> aux(4)
  end

  def aux(lst, n) do
    quantum(lst, lst |> Enum.sum() |> div(n), 1)
  end

  def quantum(lst, target, size) do
    cs = combo(lst, size) |> Enum.filter(&(Enum.sum(&1) == target))

    if length(cs) == 0 do
      quantum(lst, target, size + 1)
    else
      Enum.min_by(cs, &Enum.product/1) |> Enum.product()
    end
  end

  def combo(_, 0), do: [[]]
  def combo([], _), do: []

  def combo([h | t], n) do
    for(l <- combo(t, n - 1), do: [h | l]) ++ combo(t, n)
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.to_integer/1)
    |> Enum.to_list()
  end
end
