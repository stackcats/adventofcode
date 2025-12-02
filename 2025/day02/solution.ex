defmodule Solution do
  def part1() do
    run()
  end

  def part2() do
    run(false)
  end

  def run(twice? \\ true) do
    input()
    |> Enum.reduce(0, fn [from, to], acc ->
      for n <- from..to, reduce: acc do
        acc ->
          acc + if is_invalid("#{n}", twice?), do: n, else: 0
      end
    end)
  end

  def is_invalid(s, true) do
    i = String.length(s) |> div(2)
    {a, b} = String.split_at(s, i)
    a == b
  end

  def is_invalid(s, false) do
    "#{s}#{s}"
    |> String.slice(1..-2//1)
    |> String.contains?(s)
  end

  def input() do
    File.read!("./input.txt")
    |> String.trim()
    |> String.split(",")
    |> Enum.map(fn s ->
      Regex.run(~r/(\d+)-(\d+)/, s)
      |> tl()
      |> Enum.map(&String.to_integer/1)
    end)
  end
end
