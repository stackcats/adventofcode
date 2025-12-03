defmodule Solution do
  def part1() do
    run()
  end

  def part2() do
    run(12)
  end

  def run(l \\ 2) do
    input()
    |> Enum.map(&aux(&1, l))
    |> Enum.sum()
  end

  def aux(lst, l) do
    drop = length(lst) - l

    lst
    |> Enum.reduce({[], drop}, fn x, {st, drop} -> update_st(st, x, drop) end)
    |> elem(0)
    |> Enum.reverse()
    |> Enum.take(l)
    |> Enum.reduce(0, fn x, acc -> acc * 10 + x end)
  end

  def update_st(st, x, 0), do: {[x | st], 0}
  def update_st([], x, drop), do: {[x], drop}

  def update_st([h | t], x, drop) when drop > 0 and h < x do
    update_st(t, x, drop - 1)
  end

  def update_st(st, x, drop), do: {[x | st], drop}

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(fn s ->
      s
      |> String.trim()
      |> String.graphemes()
      |> Enum.map(&String.to_integer/1)
    end)
  end
end
