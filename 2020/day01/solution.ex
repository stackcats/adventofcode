defmodule Solution do
  def part1() do
    set = input() |> MapSet.new()

    {a, b} =
      Enum.reduce_while(set, nil, fn x, acc ->
        if MapSet.member?(set, 2020 - x) do
          {:halt, {x, 2020 - x}}
        else
          {:cont, acc}
        end
      end)

    a * b
  end

  def part2() do
    set = input() |> MapSet.new()

    for a <- set, b <- set, c <- set, a + b + c == 2020 do
      [a, b, c]
    end
    |> List.first()
    |> Enum.product()
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.to_integer/1)
    |> Enum.to_list()
  end
end
