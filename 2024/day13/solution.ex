defmodule Solution do
  def part1() do
    run(0)
  end

  def part2() do
    run(10_000_000_000_000)
  end

  def run(n) do
    input()
    |> Enum.map(fn [[x00, x10], [x01, x11], [x02, x12]] ->
      case solve({x00, x01, x02 + n}, {x10, x11, x12 + n}) do
        {x, y} -> x * 3 + y
        nil -> 0
      end
    end)
    |> Enum.sum()
  end

  def solve({x00, x01, x02}, {x10, x11, x12}) do
    a = x01 * x10 - x00 * x11
    b = x02 * x10 - x12 * x00

    if rem(b, a) == 0 do
      y = div(b, a)

      if rem(x02 - y * x01, x00) == 0 do
        {div(x02 - y * x01, x00), y}
      end
    end
  end

  def input() do
    File.read!("./input.txt")
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn s ->
      s
      |> String.split("\n")
      |> Enum.map(fn s -> Regex.scan(~r/\d+/, s) end)
      |> List.flatten()
      |> Enum.map(&String.to_integer/1)
      |> Enum.chunk_every(2)
    end)
  end
end
