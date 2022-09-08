defmodule Solution do
  def part1() do
    input()
    |> aux()
    |> then(fn {nw, ne, _} -> max(nw, ne) end)
  end

  def part2() do
    input()
    |> aux()
    |> elem(2)
  end

  def aux(lst) do
    lst
    |> Enum.reduce({0, 0, 0}, fn d, {nw, ne, ma} ->
      {nw, ne} =
        case d do
          "n" -> {nw + 1, ne + 1}
          "s" -> {nw - 1, ne - 1}
          "nw" -> {nw + 1, ne}
          "ne" -> {nw, ne + 1}
          "sw" -> {nw, ne - 1}
          "se" -> {nw - 1, ne}
        end

      {nw, ne, Enum.max([nw, ne, ma])}
    end)
  end

  def input() do
    File.stream!("./input.txt")
    |> Enum.to_list()
    |> hd()
    |> String.trim()
    |> String.split(",")
  end
end
