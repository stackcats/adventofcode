defmodule Solution do
  def part1() do
    grid =
      for i <- 0..999, j <- 0..999, reduce: %{} do
        acc -> Map.put(acc, {i, j}, false)
      end

    input()
    |> Enum.reduce(grid, &run_command/2)
    |> Map.values()
    |> Enum.filter(&(&1 == true))
    |> Enum.count()
  end

  def part2() do
    grid =
      for i <- 0..999, j <- 0..999, reduce: %{} do
        acc -> Map.put(acc, {i, j}, 0)
      end

    input()
    |> Enum.reduce(grid, &run_command2/2)
    |> Map.values()
    |> Enum.reduce(0, &(&1 + &2))
  end

  defp input() do
    reg =
      ~r/(?<type>(turn on|toggle|turn off)) (?<x1>[0-9]+),(?<y1>[0-9]+) through (?<x2>[0-9]+),(?<y2>[0-9]+)/

    File.stream!("./input.txt")
    |> Stream.map(&Regex.named_captures(reg, &1))
    |> Enum.to_list()
  end

  defp run_command(cmd, grid) do
    x1 = String.to_integer(cmd["x1"])
    x2 = String.to_integer(cmd["x2"])
    y1 = String.to_integer(cmd["y1"])
    y2 = String.to_integer(cmd["y2"])

    for i <- x1..x2, j <- y1..y2, reduce: grid do
      acc ->
        case cmd["type"] do
          "turn on" -> Map.put(acc, {i, j}, true)
          "turn off" -> Map.put(acc, {i, j}, false)
          "toggle" -> Map.put(acc, {i, j}, not acc[{i, j}])
        end
    end
  end

  defp run_command2(cmd, grid) do
    x1 = String.to_integer(cmd["x1"])
    x2 = String.to_integer(cmd["x2"])
    y1 = String.to_integer(cmd["y1"])
    y2 = String.to_integer(cmd["y2"])

    for i <- x1..x2, j <- y1..y2, reduce: grid do
      acc ->
        case cmd["type"] do
          "turn on" -> Map.put(acc, {i, j}, acc[{i, j}] + 1)
          "turn off" -> Map.put(acc, {i, j}, max(0, acc[{i, j}] - 1))
          "toggle" -> Map.put(acc, {i, j}, acc[{i, j}] + 2)
        end
    end
  end
end
