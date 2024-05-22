defmodule Solution do
  @input 1718

  def part1() do
    g = grid()

    for y <- 3..300, x <- 3..300, reduce: {0, 0, 0} do
      {acc, my, mx} ->
        left = g[{y, x - 3}] || 0
        up = g[{y - 3, x}] || 0
        left_up = g[{y - 3, x - 3}] || 0

        area = g[{y, x}] - left - up + left_up

        if area > acc do
          {area, y, x}
        else
          {acc, my, mx}
        end
    end
    |> then(fn {_, y, x} -> "#{x - 2},#{y - 2}" end)
  end

  def part2() do
    g = grid()

    for s <- 1..300, y <- s..300, x <- s..300, reduce: {0, 0, 0, 0} do
      {acc, ms, my, mx} ->
        left = g[{y, x - s}] || 0
        up = g[{y - s, x}] || 0
        left_up = g[{y - s, x - s}] || 0

        area = g[{y, x}] - left - up + left_up

        if area > acc do
          {area, s, y, x}
        else
          {acc, ms, my, mx}
        end
    end
    |> then(fn {_, s, y, x} -> "#{x - s + 1},#{y - s + 1},#{s}" end)
  end

  def grid() do
    for y <- 1..300, x <- 1..300, reduce: %{} do
      acc ->
        left = acc[{y, x - 1}] || 0
        up = acc[{y - 1, x}] || 0
        left_up = acc[{y - 1, x - 1}] || 0
        Map.put(acc, {y, x}, power(y, x) + left + up - left_up)
    end
  end

  def power(y, x) do
    rack_id = x + 10
    p = rack_id * y + @input
    p = p * rack_id
    p = div(p, 100) |> rem(10)
    p - 5
  end
end
