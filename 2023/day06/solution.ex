defmodule Solution do
  def part1() do
    input()
    |> Enum.map(fn lst ->
      lst
      |> Enum.map(&String.to_integer/1)
    end)
    |> Enum.zip()
    |> Enum.map(fn {t, d} ->
      for i <- 1..(t - 1) do
        (t - i) * i
      end
      |> Enum.count(&(&1 > d))
    end)
    |> Enum.product()
  end

  def part2() do
    [t, d] =
      input()
      |> Enum.map(fn lst ->
        lst
        |> Enum.join()
        |> String.to_integer()
      end)

    1..t
    |> Enum.find(fn i ->
      i * i - t * i + d < 0
    end)
    |> then(fn i -> t - 2 * i + 1 end)
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(fn s ->
      s
      |> String.split(~r/\s+/)
      |> tl()
    end)
    |> Enum.to_list()
  end
end
