defmodule Solution do
  def part1() do
    input()
    |> Enum.map(&Enum.sum/1)
    |> Enum.max()
  end

  def part2() do
    input()
    |> Enum.map(&Enum.sum/1)
    |> Enum.sort(&>=/2)
    |> Enum.take(3)
    |> Enum.sum()
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Enum.chunk_while(
      [],
      fn
        "", acc -> {:cont, acc, []}
        s, acc -> {:cont, [String.to_integer(s) | acc]}
      end,
      fn
        [] -> {:cont, []}
        acc -> {:cont, Enum.reverse(acc), []}
      end
    )
  end
end
