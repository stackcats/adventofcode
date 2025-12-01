defmodule Solution do
  def part1() do
    input()
    |> Enum.reduce({0, 50}, fn {d, n}, {acc, pos} ->
      if d == "L" do
        rem(pos - n, 100) |> Kernel.+(100) |> rem(100)
      else
        rem(pos + n, 100)
      end
      |> case do
        0 -> {acc + 1, 0}
        pos -> {acc, pos}
      end
    end)
    |> elem(0)
  end

  def part2() do
    input()
    |> Enum.reduce({0, 50}, fn {d, n}, acc ->
      d = if d == "L", do: -1, else: 1

      Enum.reduce(1..n, acc, fn _, {acc, pos} ->
        acc = if pos == 0, do: acc + 1, else: acc

        pos =
          case pos + d do
            x when x < 0 -> 99
            x when x > 99 -> 0
            x -> x
          end

        {acc, pos}
      end)
    end)
    |> elem(0)
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(fn s ->
      Regex.run(~r/([LR])(\d+)/, s)
      |> then(fn [_, d, n] -> {d, String.to_integer(n)} end)
    end)
  end
end
