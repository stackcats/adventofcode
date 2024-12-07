defmodule Solution do
  def part1() do
    run([&Kernel.+/2, &Kernel.*/2])
  end

  def part2() do
    run([&Kernel.+/2, &Kernel.*/2, &concat/2])
  end

  def run(ops) do
    input()
    |> Enum.reject(fn {target, lst} ->
      lst
      |> Enum.reverse()
      |> dfs(ops)
      |> Enum.find(&(&1 == target))
      |> Kernel.is_nil()
    end)
    |> Enum.map(&elem(&1, 0))
    |> Enum.sum()
  end

  def concat(a, b) do
    String.to_integer("#{b}#{a}")
  end

  def dfs([x], _), do: [x]

  def dfs([x | xs], ops) do
    dfs(xs, ops)
    |> Enum.map(&Enum.map(ops, fn op -> op.(x, &1) end))
    |> List.flatten()
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(fn s ->
      [x, xs] =
        s
        |> String.trim()
        |> String.split(": ")

      {String.to_integer(x), String.split(xs, " ") |> Enum.map(&String.to_integer/1)}
    end)
  end
end
