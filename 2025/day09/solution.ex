defmodule Solution do
  def part1() do
    input()
    |> combo(2)
    |> Enum.reduce(0, fn [a, b], acc -> max(acc, area(a, b)) end)
  end

  def part2() do
    reds = input()

    loops = [List.last(reds) | reds]

    reds
    |> combo(2)
    |> Enum.reduce(0, fn [a, b], acc ->
      if intersect?(loops, a, b), do: acc, else: max(acc, area(a, b))
    end)
  end

  def intersect?(loops, [y1, x1], [y2, x2]) do
    [y1, y2] = Enum.sort([y1, y2])
    [x1, x2] = Enum.sort([x1, x2])

    loops
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.any?(fn [[u1, v1], [u2, v2]] ->
      [u1, u2] = Enum.sort([u1, u2])
      [v1, v2] = Enum.sort([v1, v2])
      y1 < u2 and y2 > u1 and x1 < v2 and x2 > v1
    end)
  end

  def area([y1, x1], [y2, x2]) do
    (abs(y1 - y2) + 1) * (abs(x1 - x2) + 1)
  end

  def combo(_, 0), do: [[]]
  def combo([], _), do: []

  def combo([h | t], n) do
    for(l <- combo(t, n - 1), do: [h | l]) ++ combo(t, n)
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(fn s ->
      s
      |> String.trim()
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)
    end)
    |> Enum.to_list()
  end
end
