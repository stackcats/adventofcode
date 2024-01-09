defmodule Solution do
  def part1() do
    aux(2)
  end

  def part2() do
    aux(50)
  end

  def aux(r) do
    {iea, mp} = input()

    1..r
    |> Enum.reduce(mp, fn r, acc ->
      apply_iea(acc, iea, r)
    end)
    |> Enum.count(fn {_, v} -> v == "#" end)
  end

  def apply_iea(mp, iea, r) do
    {top, bottom, left, right} = border(mp)

    default = if rem(r, 2) == 0, do: "#", else: "."

    for i <- (top - 1)..(bottom + 1), j <- (left - 1)..(right + 1), reduce: %{} do
      acc ->
        [{-1, -1}, {-1, 0}, {-1, 1}, {0, -1}, {0, 0}, {0, 1}, {1, -1}, {1, 0}, {1, 1}]
        |> Enum.map(fn {dx, dy} ->
          case Map.get(mp, {i + dx, j + dy}, default) do
            "#" -> "1"
            "." -> "0"
          end
        end)
        |> Enum.join()
        |> String.to_integer(2)
        |> then(&iea[&1])
        |> then(&Map.put(acc, {i, j}, &1))
    end
  end

  def border(mp) do
    {{top, _}, {bottom, _}} = mp |> Map.keys() |> Enum.min_max_by(fn {i, _} -> i end)
    {{_, left}, {_, right}} = mp |> Map.keys() |> Enum.min_max_by(fn {_, j} -> j end)

    {top, bottom, left, right}
  end

  def input() do
    [iea, mp] =
      File.read!("./input.txt")
      |> String.trim()
      |> String.split("\n\n")

    iea =
      iea
      |> String.graphemes()
      |> Enum.with_index()
      |> Map.new(fn {c, i} -> {i, c} end)

    mp =
      mp
      |> String.split("\n")
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {row, i}, acc ->
        row
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.reduce(acc, fn {c, j}, acc ->
          Map.put(acc, {i, j}, c)
        end)
      end)

    {iea, mp}
  end
end
