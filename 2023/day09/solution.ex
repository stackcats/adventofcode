defmodule Solution do
  def part1() do
    input()
    |> complete_all()
    |> elem(1)
  end

  def part2() do
    input()
    |> complete_all()
    |> elem(0)
  end

  def complete_all(lst) do
    lst
    |> Enum.reduce({0, 0}, fn lst, {ll, rr} ->
      {l, r} = complete(lst)
      {ll + l, rr + r}
    end)
  end

  def complete(xs) do
    if Enum.all?(xs, &(&1 == 0)) do
      {0, 0}
    else
      xs
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.reduce([], fn [a, b], acc ->
        [b - a | acc]
      end)
      |> Enum.reverse()
      |> complete()
      |> then(fn {l, r} ->
        {hd(xs) - l, List.last(xs) + r}
      end)
    end
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.split(&1, " "))
    |> Stream.map(fn lst -> Enum.map(lst, &String.to_integer/1) end)
    |> Enum.to_list()
  end
end
