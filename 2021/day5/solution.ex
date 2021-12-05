defmodule Solution do
  def part1() do
    input()
    |> Enum.reduce(%{}, &draw_part1/2)
    |> Enum.reduce(0, fn {_, v}, acc -> acc + if v >= 2, do: 1, else: 0 end)
  end

  def part2() do
    input()
    |> Enum.reduce(%{}, &draw_part2/2)
    |> Enum.reduce(0, fn {_, v}, acc -> acc + if v >= 2, do: 1, else: 0 end)
  end

  defp draw_vertical(y1, y2, x, acc) do
    y1..y2 |> Enum.reduce(acc, fn y, acc -> Map.update(acc, {x, y}, 1, &(&1 + 1)) end)
  end

  defp draw_horizontal(x1, x2, y, acc) do
    x1..x2 |> Enum.reduce(acc, fn x, acc -> Map.update(acc, {x, y}, 1, &(&1 + 1)) end)
  end

  defp draw_diagonal(x1, y1, x2, y2, acc) do
    Enum.zip([x1..x2, y1..y2])
    |> Enum.reduce(acc, fn {x, y}, acc -> Map.update(acc, {x, y}, 1, &(&1 + 1)) end)
  end

  defp draw_part1(nil, acc), do: acc

  defp draw_part1([x1, y1, x2, y2], acc) do
    cond do
      x1 == x2 ->
        draw_vertical(y1, y2, x1, acc)

      y1 == y2 ->
        draw_horizontal(x1, x2, y1, acc)

      true ->
        acc
    end
  end

  defp draw_part2(nil, acc), do: acc

  defp draw_part2([x1, y1, x2, y2], acc) do
    cond do
      x1 == x2 ->
        draw_vertical(y1, y2, x1, acc)

      y1 == y2 ->
        draw_horizontal(x1, x2, y1, acc)

      abs(x1 - x2) == abs(y1 - y2) ->
        draw_diagonal(x1, y1, x2, y2, acc)

      true ->
        acc
    end
  end

  defp input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&parse_coordinates/1)
    |> Enum.to_list()
  end

  defp parse_coordinates(line) do
    line
    |> String.replace(" ", "")
    |> String.split(["->", ","])
    |> Enum.map(&String.to_integer/1)
  end
end
