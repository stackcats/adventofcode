defmodule Solution do
  import Bitwise

  def part1() do
    output(51_064_159, [])
  end

  def part2() do
    [2, 4, 1, 5, 7, 5, 1, 6, 0, 3, 4, 6, 5, 5, 3, 0]
    |> Enum.reverse()
    |> Enum.reduce([0], fn out, acc ->
      for a <- acc, i <- 0..7, run((a <<< 3) + i) == out do
        (a <<< 3) + i
      end
    end)
    |> Enum.min()
  end

  def output(0, lst) do
    lst
    |> Enum.reverse()
    |> Enum.map(&Integer.to_string/1)
    |> Enum.join(",")
  end

  def output(a, lst) do
    output(a >>> 3, [run(a) | lst])
  end

  def run(a) do
    """
    b = a % 8
    b = b ^ 5
    c = a / (2 ** b)
    b = b ^ 6
    b = b ^ c
    out b
    a = a / 8
    """

    b = rem(a, 8)
    b = Bitwise.bxor(b, 5)
    c = a >>> b
    b = Bitwise.bxor(b, 6)
    b = Bitwise.bxor(b, c)
    rem(b, 8)
  end
end
