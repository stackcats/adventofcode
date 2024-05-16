defmodule Solution do
  def part1() do
    distances() |> Enum.max()
  end

  def part2() do
    distances() |> Enum.count(&(&1 >= 1000))
  end

  def distances() do
    start = {0, 0}

    input()
    |> tl()
    |> run(start, [], %{start => 0})
    |> Map.values()
  end

  def run([s | ss], curr, st, mp) do
    case s do
      "$" ->
        mp

      "(" ->
        run(ss, curr, [curr | st], mp)

      ")" ->
        run(ss, hd(st), tl(st), mp)

      "|" ->
        run(ss, hd(st), st, mp)

      _ ->
        next = move(s, curr)
        distance = mp[curr] + 1
        mp = Map.update(mp, next, distance, &min(&1, distance))
        run(ss, next, st, mp)
    end
  end

  def move("N", {x, y}), do: {x - 1, y}
  def move("S", {x, y}), do: {x + 1, y}
  def move("E", {x, y}), do: {x, y + 1}
  def move("W", {x, y}), do: {x, y - 1}

  def input() do
    File.read!("./input.txt") |> String.graphemes()
  end
end
