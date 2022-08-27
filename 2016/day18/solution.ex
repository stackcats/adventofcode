defmodule Solution do
  def part1() do
    input()
    |> gen_map(40)
  end

  def part2() do
    input()
    |> gen_map(400_000)
  end

  def gen_map(first_row, num_of_row) do
    for _ <- 1..num_of_row, reduce: {0, first_row} do
      {total_safes, row} ->
        safes = num_of_safes(row)

        next_row =
          row |> Enum.reduce(%{}, fn {i, _}, acc -> Map.put(acc, i, next_tile(row, i)) end)

        {total_safes + safes, next_row}
    end
    |> elem(0)
  end

  def next_tile(row, i) do
    case {Map.get(row, i - 1, "."), row[i], Map.get(row, i + 1, ".")} do
      {"^", "^", "."} -> "^"
      {".", "^", "^"} -> "^"
      {"^", ".", "."} -> "^"
      {".", ".", "^"} -> "^"
      _ -> "."
    end
  end

  def num_of_safes(row) do
    row |> Map.values() |> Enum.count(&(&1 == "."))
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Enum.to_list()
    |> hd()
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {c, i}, acc -> Map.put(acc, i, c) end)
  end
end
