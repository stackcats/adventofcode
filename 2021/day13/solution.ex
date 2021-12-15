defmodule Solution do
  def part1() do
    ins = instruction()

    input()
    |> to_map()
    |> fold(List.first(ins))
    |> count_dot()
  end

  def part2() do
    map =
      input()
      |> to_map()

    instruction()
    |> Enum.reduce(map, fn ins, map -> fold(map, ins) end)
    |> print()
  end

  defp input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(fn line -> String.split(line, ",") |> Enum.map(&String.to_integer/1) end)
    |> Enum.to_list()
  end

  defp instruction() do
    File.stream!("./instructions.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(fn line -> String.split(line, " ") end)
    |> Stream.map(fn [_, _, k] -> k end)
    |> Stream.map(fn line -> String.split(line, "=") end)
    |> Stream.map(fn [i, n] -> {i, String.to_integer(n)} end)
    |> Enum.to_list()
  end

  defp to_map(lst) do
    {m, row, col} =
      lst
      |> Enum.reduce({%{}, 0, 0}, fn [x, y], {m, row, col} ->
        {Map.put(m, {y, x}, "#"), max(row, y), max(col, x)}
      end)
  end

  defp count_dot({m, row, col}) do
    for i <- 0..row, j <- 0..col, reduce: 0 do
      acc -> acc + if Map.has_key?(m, {i, j}), do: 1, else: 0
    end
  end

  defp print({m, row, col}) do
    IO.puts("")

    for i <- 0..row do
      for j <- 0..col do
        g = Map.get(m, {i, j}, ".")
        IO.write("#{g} ")
      end

      IO.puts("")
    end
  end

  defp fold({m, row, col}, {"x", x}) do
    m =
      for i <- 0..row, j <- (x + 1)..col, reduce: m do
        acc -> if Map.has_key?(acc, {i, j}), do: Map.put(acc, {i, 2 * x - j}, "#"), else: acc
      end

    {m, row, x - 1}
  end

  defp fold({m, row, col}, {"y", y}) do
    m =
      for i <- (y + 1)..row, j <- 0..col, reduce: m do
        acc -> if Map.has_key?(acc, {i, j}), do: Map.put(acc, {2 * y - i, j}, "#"), else: acc
      end

    {m, y - 1, col}
  end
end
