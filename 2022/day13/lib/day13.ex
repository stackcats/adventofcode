defmodule Day13 do
  def part1() do
    input()
    |> Enum.chunk_every(2)
    |> Enum.with_index()
    |> Enum.reduce(0, fn {[left, right], i}, acc ->
      if ordered?(left, right) == -1 do
        acc + i + 1
      else
        acc
      end
    end)
  end

  def part2() do
    packets = input()

    packets =
      [[[6]], [[2]] | packets]
      |> Enum.sort(fn a, b -> ordered?(a, b) < 0 end)

    a = packets |> Enum.find_index(&(&1 == [[2]]))
    b = packets |> Enum.find_index(&(&1 == [[6]]))
    (a + 1) * (b + 1)
  end

  def ordered?([], []), do: 0
  def ordered?([], _right), do: -1
  def ordered?(_left, []), do: 1

  def ordered?([l | ls], [r | rs]) do
    if is_integer(l) && is_integer(r) do
      cond do
        l < r -> -1
        l == r -> ordered?(ls, rs)
        true -> 1
      end
    else
      l = if is_integer(l), do: [l], else: l
      r = if is_integer(r), do: [r], else: r

      case ordered?(l, r) do
        -1 -> -1
        0 -> ordered?(ls, rs)
        1 -> 1
      end
    end
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.filter(&(&1 != ""))
    |> Stream.map(&Jason.decode!(&1))
    |> Enum.to_list()
  end
end
