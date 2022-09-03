defmodule Solution do
  def part1() do
    input()
    |> aux()
  end

  def part2() do
    xs = input()
    ct = length(xs)

    (xs ++ [{ct + 1, 0, 11}])
    |> aux()
  end

  def aux(xs, delta \\ 0) do
    if Enum.all?(xs, fn {i, init, all} -> rem(init + delta + i, all) == 0 end) do
      delta
    else
      aux(xs, delta + 1)
    end
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(fn s ->
      r =
        ~r/Disc #(?<i>(\d)) has (?<all>(\d+)) positions; at time=0, it is at position (?<init>(\d+))./

      cap = Regex.named_captures(r, s)

      {
        String.to_integer(cap["i"]),
        String.to_integer(cap["init"]),
        String.to_integer(cap["all"])
      }
    end)
    |> Enum.to_list()
  end
end
