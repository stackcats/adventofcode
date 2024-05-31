defmodule Solution do
  def part1() do
    input()
    |> run(4, fn g, {x, y}, {dx, dy} -> g[{x + dx, y + dy}] end)
    |> Enum.count(fn {_, v} -> v == "#" end)
  end

  def part2() do
    input()
    |> run(5, &first_seat/3)
    |> Enum.count(fn {_, v} -> v == "#" end)
  end

  def first_seat(g, {x, y}, {dx, dy}) do
    pos = {x + dx, y + dy}

    case g[pos] do
      "." -> first_seat(g, pos, {dx, dy})
      s -> s
    end
  end

  def run(g, seats, find_seat) do
    ng = next(g, seats, find_seat)

    if ng == g do
      g
    else
      run(ng, seats, find_seat)
    end
  end

  def next(g, seats, find_seat) do
    g
    |> Map.new(fn
      {pos, "."} ->
        {pos, "."}

      {pos, seat} ->
        occupied =
          [{-1, -1}, {-1, 0}, {-1, 1}, {0, 1}, {1, 1}, {1, 0}, {1, -1}, {0, -1}]
          |> Enum.count(fn d -> find_seat.(g, pos, d) == "#" end)

        cond do
          seat == "L" and occupied == 0 -> {pos, "#"}
          seat == "#" and occupied >= seats -> {pos, "L"}
          true -> {pos, seat}
        end
    end)
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.with_index()
    |> Enum.reduce(%{}, fn {s, i}, acc ->
      s
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {c, j}, acc ->
        Map.put(acc, {i, j}, c)
      end)
    end)
  end
end
