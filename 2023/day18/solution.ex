# https://en.wikipedia.org/wiki/Shoelace_formula
# https://en.wikipedia.org/wiki/Pick%27s_theorem
defmodule Solution do
  def part1() do
    input() |> shoelace()
  end

  def part2() do
    input(2) |> shoelace()
  end

  def shoelace(lst) do
    lst
    |> Enum.reduce({{0, 0}, 0, 0, 0}, fn {d, n}, {{x, y}, sum1, sum2, border_len} ->
      {dx, dy} =
        case d do
          "R" -> {0, 1}
          "L" -> {0, -1}
          "U" -> {-1, 0}
          "D" -> {1, 0}
        end

      nx = x + n * dx
      ny = y + n * dy

      {{nx, ny}, sum1 + x * ny, sum2 + y * nx, border_len + n}
    end)
    |> then(fn {_, s1, s2, b} ->
      area = abs(s1 - s2) |> div(2)
      area + div(b, 2) + 1
    end)
  end

  def input(p \\ 1) do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(fn s ->
      [d, n, h] =
        s
        |> String.replace(~r/[#()]/, "")
        |> String.split(" ")

      if p == 1 do
        {d, String.to_integer(n)}
      else
        {n, d} = String.split_at(h, -1)
        d = %{"0" => "R", "1" => "D", "2" => "L", "3" => "U"}[d]
        {d, String.to_integer(n, 16)}
      end
    end)
    |> Enum.to_list()
  end
end
