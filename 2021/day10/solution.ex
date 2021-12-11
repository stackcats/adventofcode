defmodule Solution do
  @right ")]}>"

  def part1() do
    input()
    |> Enum.reduce(%{}, fn s, acc -> Map.update(acc, corrupted(s, []), 1, &(&1 + 1)) end)
    |> Enum.reduce(0, fn {k, v}, acc -> corrupted_points(k) * v + acc end)
  end

  def part2() do
    lst =
      input()
      |> Enum.flat_map(fn s -> incomplete(s, []) end)
      |> Enum.map(fn s -> incomplete_score(s, 0) end)
      |> Enum.sort()

    Enum.at(lst, Enum.count(lst) |> div(2))
  end

  defp corrupted([], _st), do: ""

  defp corrupted([x | xs], []) do
    if String.contains?(@right, x) do
      x
    else
      corrupted(xs, [x])
    end
  end

  defp corrupted([x | xs], [y | ys] = st) do
    if not String.contains?(@right, x) do
      corrupted(xs, [x | st])
    else
      cond do
        y == "(" && x == ")" -> corrupted(xs, ys)
        y == "[" && x == "]" -> corrupted(xs, ys)
        y == "{" && x == "}" -> corrupted(xs, ys)
        y == "<" && x == ">" -> corrupted(xs, ys)
        true -> x
      end
    end
  end

  defp corrupted_points(")"), do: 3
  defp corrupted_points("]"), do: 57
  defp corrupted_points("}"), do: 1197
  defp corrupted_points(">"), do: 25137
  defp corrupted_points(_), do: 0

  defp incomplete([], st), do: [st]

  defp incomplete([x | xs], []) do
    if String.contains?(@right, x) do
      []
    else
      incomplete(xs, [x])
    end
  end

  defp incomplete([x | xs], [y | ys] = st) do
    if not String.contains?(@right, x) do
      incomplete(xs, [x | st])
    else
      cond do
        y == "(" && x == ")" -> incomplete(xs, ys)
        y == "[" && x == "]" -> incomplete(xs, ys)
        y == "{" && x == "}" -> incomplete(xs, ys)
        y == "<" && x == ">" -> incomplete(xs, ys)
        true -> []
      end
    end
  end

  defp incomplete_points("("), do: 1
  defp incomplete_points("["), do: 2
  defp incomplete_points("{"), do: 3
  defp incomplete_points("<"), do: 4

  defp incomplete_score([], ans), do: ans

  defp incomplete_score([x | xs], ans) do
    incomplete_score(xs, 5 * ans + incomplete_points(x))
  end

  defp input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.graphemes/1)
    |> Enum.to_list()
  end
end
