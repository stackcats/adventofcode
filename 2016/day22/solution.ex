defmodule Solution do
  defmodule Node do
    defstruct [:size, :used, :avail, :percent]

    def from_map(m) do
      opts = m |> Map.to_list() |> Enum.map(fn {k, v} -> {String.to_existing_atom(k), v} end)
      struct(__MODULE__, opts)
    end
  end

  def part1() do
    grid = input()

    for {k1, v1} <- grid, {k2, v2} <- grid, k1 != k2, reduce: 0 do
      acc -> acc + if v1.used > 0 && v1.used <= v2.avail, do: 1, else: 0
    end
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.drop(2)
    |> Stream.map(&String.trim/1)
    |> Stream.map(fn s ->
      ~r/.*-x(?<x>\d+)-y(?<y>\d+)\s*(?<size>\d+)T\s*(?<used>\d+)T\s*(?<avail>\d+)T\s*(?<percent>\d+)%/
      |> Regex.named_captures(s)
      |> Enum.reduce(%{}, fn {k, v}, acc ->
        Map.put(acc, k, String.to_integer(v))
      end)
    end)
    |> Enum.reduce(%{}, fn cap, acc ->
      Map.put(acc, {cap["x"], cap["y"]}, Node.from_map(cap))
    end)
  end
end
