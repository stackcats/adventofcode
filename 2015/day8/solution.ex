defmodule Solution do
  def part1() do
    x =
      input()
      |> Enum.map(&String.length/1)
      |> Enum.sum()

    y =
      input()
      |> Enum.map(fn s ->
        s
        |> String.replace("\\\\", "+")
        |> String.replace("\\\"", "+")
        |> String.replace(~r/\\x../, "+")
      end)
      |> Enum.map(fn s -> String.length(s) - 2 end)
      |> Enum.sum()

    x - y
  end

  def part2() do
    x =
      input()
      |> Enum.map(&String.length/1)
      |> Enum.sum()

    y =
      input()
      |> Enum.map(fn s ->
        s
        |> String.replace("\\", "++")
        |> String.replace("\"", "++")
        |> String.replace(~r/\\x../, "+++++")
      end)
      |> Enum.map(fn s -> String.length(s) + 2 end)
      |> Enum.sum()

    y - x
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Enum.to_list()
  end
end
