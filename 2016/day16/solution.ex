defmodule Solution do
  @s "01110110101001000"

  def part1() do
    @s
    |> String.graphemes()
    |> aux(272)
  end

  def part2() do
    @s
    |> String.graphemes()
    |> aux(35_651_584)
  end

  def aux(a, len) do
    if length(a) < len do
      a |> next() |> aux(len)
    else
      a
      |> Enum.take(len)
      |> checksum()
    end
  end

  def next(a) do
    a
    |> Enum.reverse()
    |> Enum.map(fn c ->
      if c == "1", do: "0", else: "1"
    end)
    |> then(fn b ->
      a ++ ["0"] ++ b
    end)
  end

  def checksum(xs) do
    if xs |> length() |> odd?() do
      xs |> Enum.join()
    else
      xs
      |> Enum.chunk_every(2)
      |> Enum.map(fn [a, b] ->
        if a == b, do: "1", else: "0"
      end)
      |> checksum()
    end
  end

  def odd?(n) do
    rem(n, 2) == 1
  end
end
