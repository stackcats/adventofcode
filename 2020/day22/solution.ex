defmodule Solution do
  def part1() do
    {p1, p2} = input()

    play(p1, p2)
    |> elem(1)
    |> score()
  end

  def part2() do
    {p1, p2} = input()

    play(p1, p2, %MapSet{}, true)
    |> elem(1)
    |> score()
  end

  def score(lst) do
    lst
    |> Enum.reverse()
    |> Enum.with_index(1)
    |> Enum.map(fn {n, i} -> n * i end)
    |> Enum.sum()
  end

  def play(p1, p2, st \\ %MapSet{}, r? \\ false)
  def play([], ys, _, _), do: {false, ys}
  def play(xs, [], _, _), do: {true, xs}

  def play([x | xs] = p1, [y | ys] = p2, st, r?) do
    if r? and {p1, p2} in st do
      {true, p1}
    else
      st = MapSet.put(st, {p1, p2})

      {win?, _} =
        if r? and length(xs) >= x and length(ys) >= y do
          play(Enum.take(xs, x), Enum.take(ys, y), %MapSet{}, r?)
        else
          {x > y, nil}
        end

      if win? do
        play(xs ++ [x, y], ys, st, r?)
      else
        play(xs, ys ++ [y, x], st, r?)
      end
    end
  end

  def input() do
    [p1, p2] =
      File.read!("input.txt")
      |> String.split("\n\n", trim: true)

    {parse(p1), parse(p2)}
  end

  def parse(s) do
    s
    |> String.split("\n", trim: true)
    |> Enum.drop(1)
    |> Enum.map(&String.to_integer/1)
  end
end
