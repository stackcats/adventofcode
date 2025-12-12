defmodule Solution do
  def part1() do
    input()
    |> Enum.count(fn [w, h | reqs] ->
      w * h >= Enum.sum(reqs) * 7
    end)
  end

  def input() do
    File.read!("./input.txt")
    |> String.split("\n\n")
    |> List.last()
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_region/1)
  end

  def parse_region(s) do
    Regex.scan(~r/(\d+)/, s)
    |> Enum.map(fn v -> hd(v) |> String.to_integer() end)
  end
end
