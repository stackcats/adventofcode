defmodule Solution do
  def part1() do
    input()
    |> ids()
    |> Enum.max()
  end

  def part2() do
    lst =
      input()
      |> ids()
      |> Enum.sort()

    Enum.zip(lst, tl(lst))
    |> Enum.filter(fn {a, b} -> b - a != 1 end)
    |> hd()
    |> elem(1)
    |> then(&(&1 - 1))
  end

  defp ids(lst) do
    Enum.map(lst, fn each ->
      {h, v} = Enum.split(each, 7)
      r = find(h, 0, 127, "F", 6)
      c = find(v, 0, 7, "L", 2)
      r * 8 + c
    end)
  end

  defp find(lst, l, r, char, len) do
    lst
    |> Enum.with_index()
    |> Enum.reduce({l, r}, fn {c, i}, {l, r} ->
      if i == len do
        if c == char, do: l, else: r
      else
        m = (l + r) / 2
        if c == char, do: {l, floor(m)}, else: {ceil(m), r}
      end
    end)
  end

  defp input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.graphemes/1)
    |> Enum.to_list()
  end
end
