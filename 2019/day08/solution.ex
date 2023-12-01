defmodule Solution do
  @width 25
  @height 6

  @black "0"
  @white "1"
  @transparent "2"

  def part1() do
    input()
    |> Enum.chunk_every(@width * @height)
    |> Enum.min_by(fn chunk ->
      chunk |> Enum.count(fn c -> c == "0" end)
    end)
    |> Enum.reduce({0, 0}, fn c, {one, two} ->
      case c do
        "1" -> {one + 1, two}
        "2" -> {one, two + 1}
        _ -> {one, two}
      end
    end)
    |> then(fn {a, b} -> a * b end)
  end

  def part2() do
    input()
    |> Enum.chunk_every(@width * @height)
    |> Enum.reduce(%{}, fn chunk, image ->
      chunk
      |> Enum.with_index()
      |> Enum.reduce(image, fn {c, i}, image ->
        Map.update(image, i, c, fn upper ->
          case upper do
            @transparent -> c
            _ -> upper
          end
        end)
      end)
    end)
    |> print()
  end

  def print(image) do
    for i <- 1..@height do
      for j <- 1..@width, into: "" do
        k = (i - 1) * @width + j - 1
        if image[k] == @black, do: " ", else: "#"
      end
    end
    |> Enum.join("\n")
    |> IO.puts()
  end

  def input() do
    File.stream!("./input.txt")
    |> Enum.to_list()
    |> hd()
    |> String.trim()
    |> String.graphemes()
  end
end
