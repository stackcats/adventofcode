defmodule Solution do
  def part1() do
    input()
    |> Enum.reject(&String.starts_with?(&1, "d"))
    |> Enum.map(&mul/1)
    |> Enum.sum()
  end

  def part2() do
    input()
    |> Enum.reduce({0, true}, fn
      "do()", {n, _} -> {n, true}
      "don't()", {n, _} -> {n, false}
      _, {n, false} -> {n, false}
      s, {n, true} -> {mul(s) + n, true}
    end)
    |> elem(0)
  end

  def mul(s) do
    Regex.scan(~r/\d+/, s)
    |> Enum.map(fn r -> hd(r) |> String.to_integer() end)
    |> Enum.product()
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(fn s ->
      Regex.scan(~r/do\(\)|mul\(\d+,\d+\)|don\'t\(\)/, String.trim(s))
    end)
    |> Enum.to_list()
    |> List.flatten()
  end
end
