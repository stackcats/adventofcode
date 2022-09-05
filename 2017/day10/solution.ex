defmodule Solution do
  def part1 do
    lst = 0..4 |> Enum.to_list()

    input()
    |> hash(lst, 0)
    |> tap(&IO.inspect/1)
    |> then(fn [a, b | _] -> a * b end)
  end

  def hash([], prev, tail, _), do: prev ++ tail

  def hash([x | xs], prev, tail, skip) do
    if x > length(tail) do
    end

    lst = Enum.reverse(h) ++ t
    {h, t} = Enum.split(lst, x + skip)
    IO.inspect({h, t})
    hash(xs, t ++ h, skip + 1)
  end

  def input() do
    File.stream!("./input.txt")
    |> Enum.to_list()
    |> hd()
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end
end
