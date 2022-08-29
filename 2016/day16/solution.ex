defmodule Solution do
  def part1() do
    aux("01110110101001000", 272)
  end

  def aux(a, len) do
    if String.length(a) < len do
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
      xs
    end
  end

  def odd?(n) do
    rem(n, 2) == 1
  end
end
