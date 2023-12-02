defmodule Solution do
  def part1() do
    input()
    |> Enum.with_index()
    |> Enum.filter(fn {game, _} ->
      game
      |> Enum.all?(fn sets ->
        sets
        |> Enum.all?(fn {color, n} ->
          case color do
            "red" -> n <= 12
            "green" -> n <= 13
            "blue" -> n <= 14
          end
        end)
      end)
    end)
    |> Enum.reduce(0, fn {_, i}, acc -> acc + i + 1 end)
  end

  def part2() do
    input()
    |> Enum.reduce(0, fn game, acc ->
      game
      |> Enum.reduce({0, 0, 0}, fn sets, {r, g, b} ->
        sets
        |> Enum.reduce({r, g, b}, fn {color, n}, {r, g, b} ->
          case color do
            "red" -> {max(n, r), g, b}
            "green" -> {r, max(n, g), b}
            "blue" -> {r, g, max(n, b)}
          end
        end)
      end)
      |> then(fn {r, g, b} -> acc + r * g * b end)
    end)
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(fn s ->
      s
      |> String.split(": ")
      |> List.last()
    end)
    |> Stream.map(&String.split(&1, "; "))
    |> Stream.map(fn sets ->
      sets
      |> Enum.map(fn cubes ->
        cubes
        |> String.split(", ")
        |> Enum.map(fn s ->
          [n, color] = String.split(s, " ")
          {color, String.to_integer(n)}
        end)
      end)
    end)
    |> Enum.to_list()
  end
end
