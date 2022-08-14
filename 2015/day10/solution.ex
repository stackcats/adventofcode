defmodule Solution do
  def part1() do
    aux(40)
  end

  def part2() do
    aux(50)
  end

  def aux(n) do
    for _ <- 1..n, reduce: input() do
      acc ->
        count(tl(acc), hd(acc), 1, [])
    end
    |> length()
  end

  def count([], prev, ct, lst) do
    [prev, ct | lst] |> Enum.reverse()
  end

  def count([x | xs], prev, ct, lst) do
    if x == prev do
      count(xs, prev, ct + 1, lst)
    else
      count(xs, x, 1, [prev, ct | lst])
    end
  end

  def input() do
    [1, 1, 1, 3, 1, 2, 2, 1, 1, 3]
  end
end
