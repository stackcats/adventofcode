defmodule Solution do
  def part1() do
    1..10
    |> Enum.reduce(input(), fn _, acc -> run(acc) end)
    |> count()
  end

  def part2() do
    minutes = 1_000_000_000

    1..minutes
    |> Enum.reduce_while({[], input()}, fn _, {lst, mp} ->
      case Enum.find_index(lst, &(&1 == mp)) do
        nil ->
          {:cont, {lst ++ [mp], run(mp)}}

        n ->
          cycle_len = length(lst) - n

          ct =
            lst
            |> Enum.drop(n)
            |> Enum.at(rem(minutes - n, cycle_len))
            |> count()

          {:halt, ct}
      end
    end)
  end

  def count(mp) do
    trees = Enum.count(mp, fn {_, v} -> v == "|" end)
    lumberyards = Enum.count(mp, fn {_, v} -> v == "#" end)

    trees * lumberyards
  end

  def run(mp) do
    Map.new(mp, fn {curr, c} ->
      case c do
        "." ->
          if adjacent(mp, curr, "|") >= 3, do: "|", else: "."

        "|" ->
          if adjacent(mp, curr, "#") >= 3, do: "#", else: "|"

        "#" ->
          if adjacent(mp, curr, "#") >= 1 and adjacent(mp, curr, "|") >= 1, do: "#", else: "."
      end
      |> then(fn c -> {curr, c} end)
    end)
  end

  def adjacent(mp, {x, y}, target) do
    [{-1, -1}, {-1, 0}, {-1, 1}, {0, 1}, {1, 1}, {1, 0}, {1, -1}, {0, -1}]
    |> Enum.count(fn {dx, dy} -> mp[{x + dx, y + dy}] == target end)
  end

  def input() do
    File.stream!("input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.graphemes/1)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {row, i}, acc ->
      row
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {c, j}, acc ->
        Map.put(acc, {i, j}, c)
      end)
    end)
  end
end
