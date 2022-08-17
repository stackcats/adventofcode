defmodule Solution do
  @target 29_000_000
  def part1() do
    aux(1)
  end

  def aux(n) do
    if factor(n) * 10 >= @target do
      n
    else
      aux(n + 1)
    end
  end

  def factor(n) do
    factor(2, n, %{})
    |> Enum.reduce(1, fn {k, v}, acc ->
      div(k ** (v + 1) - 1, k - 1) * acc
    end)
  end

  def factor(d, n, p) when d > n do
    p
  end

  def factor(d, n, p) do
    if rem(n, d) == 0 do
      factor(d, div(n, d), Map.update(p, d, 1, &(&1 + 1)))
    else
      factor(d + 1, n, p)
    end
  end
end
