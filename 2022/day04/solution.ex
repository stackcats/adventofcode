defmodule Solution do
  def part1() do
    input()
    |> Enum.count(fn {[x1, y1], [x2, y2]} ->
      (x1 <= x2 && y1 >= y2) || (x2 <= x1 && y2 >= y1)
    end)
  end

  def part2() do
    lst = input()

    ct =
      lst
      |> Enum.count(fn {[x1, y1], [x2, y2]} ->
        y1 < x2 || y2 < x1
      end)

    length(lst) - ct
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(fn s ->
      [s1, s2] = s |> String.split(",")
      {s_to_t(s1), s_to_t(s2)}
    end)
    |> Enum.to_list()
  end

  def s_to_t(s) do
    s
    |> String.split("-")
    |> Enum.map(&String.to_integer/1)
  end
end
