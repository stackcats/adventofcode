defmodule Solution do
  def part1() do
    {m, row, col} = input() |> to_map()

    {g, e} =
      Enum.reduce(0..(col - 1), {"", ""}, fn j, {g, e} ->
        {ones, zeros} =
          Enum.reduce(0..(row - 1), {0, 0}, fn i, {ones, zeros} ->
            if Map.get(m, {i, j}) == "1" do
              {ones + 1, zeros}
            else
              {ones, zeros + 1}
            end
          end)

        IO.inspect("#{ones}, #{zeros}")

        if ones > zeros do
          {g <> "1", e <> "0"}
        else
          {g <> "0", e <> "1"}
        end
      end)

    String.to_integer(g, 2) * String.to_integer(e, 2)
  end

  def part2() do
    {m, row, col} = input() |> to_map()
    oxygen = m
    co2 = m
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&(&1 |> String.trim() |> String.graphemes()))
    |> Enum.to_list()
  end

  def to_map(lst) do
    row = Enum.count(lst)
    col = lst |> List.first() |> Enum.count()

    acc =
      lst
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {each, i}, acc ->
        each
        |> Enum.with_index()
        |> Enum.reduce(acc, fn {c, j}, acc ->
          Map.put(acc, {i, j}, c)
        end)
      end)

    {acc, row, col}
  end
end
