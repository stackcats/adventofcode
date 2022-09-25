defmodule Solution do
  defmodule Claim do
    defstruct [:id, :left, :top, :wide, :tall]
  end

  def part1() do
    input()
    |> gen_grid()
    |> Map.values()
    |> Enum.count(&(&1 > 1))
  end

  def part2() do
    claims = input()

    grid = gen_grid(claims)

    claims
    |> Enum.find(fn claim ->
      0..(claim.tall - 1)
      |> Enum.all?(fn i ->
        0..(claim.wide - 1)
        |> Enum.all?(fn j ->
          grid[{i + claim.top, j + claim.left}] == 1
        end)
      end)
    end)
    |> Map.get(:id)
  end

  def gen_grid(claims) do
    claims
    |> Enum.reduce(%{}, fn claim, grid ->
      for i <- 0..(claim.tall - 1), j <- 0..(claim.wide - 1), reduce: grid do
        acc ->
          Map.update(acc, {i + claim.top, j + claim.left}, 1, &(&1 + 1))
      end
    end)
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&parse/1)
    |> Enum.to_list()
  end

  def parse(s) do
    ~r/#(?<id>\d+) @ (?<left>\d+),(?<top>\d+): (?<wide>\d+)x(?<tall>\d+)/
    |> Regex.named_captures(s)
    |> Enum.reduce(%Claim{}, fn {k, v}, acc ->
      Map.put(acc, String.to_atom(k), String.to_integer(v))
    end)
  end
end
