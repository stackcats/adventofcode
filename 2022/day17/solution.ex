defmodule Solution do
  def part1() do
    aux(2022)
  end

  def part2() do
    aux(1_000_000_000_000)
  end

  def aux(rocks) do
    pattern = input()
    chamber = 0..6 |> MapSet.new(fn y -> {0, y} end)
    run(chamber, 0, pattern, 0, 0, %{}, rocks)
  end

  def gen_rock(i, height) do
    case rem(i, 5) do
      0 -> [{0, 2}, {0, 3}, {0, 4}, {0, 5}]
      1 -> [{0, 3}, {1, 2}, {1, 3}, {1, 4}, {2, 3}]
      2 -> [{0, 2}, {0, 3}, {0, 4}, {1, 4}, {2, 4}]
      3 -> [{0, 2}, {1, 2}, {2, 2}, {3, 2}]
      4 -> [{0, 2}, {0, 3}, {1, 2}, {1, 3}]
    end
    |> Enum.map(fn {x, y} -> {x + height + 4, y} end)
  end

  def move_level(rock, p, chamber) do
    if Enum.all?(rock, fn {x, y} ->
         ny = y + p
         ny >= 0 && ny <= 6 && not MapSet.member?(chamber, {x, ny})
       end) do
      Enum.map(rock, fn {x, y} -> {x, y + p} end)
    else
      rock
    end
  end

  def move_down(rock, chamber) do
    if Enum.all?(rock, fn {x, y} ->
         not MapSet.member?(chamber, {x - 1, y})
       end) do
      Enum.map(rock, fn {x, y} -> {x - 1, y} end)
    else
      rock
    end
  end

  def falling(rock, chamber, pattern, pi, highest) do
    rock = move_level(rock, pattern[pi], chamber)
    pi = rem(pi + 1, map_size(pattern))
    new_rock = move_down(rock, chamber)

    if new_rock == rock do
      chamber = new_rock |> MapSet.new() |> MapSet.union(chamber)
      highest = new_rock |> Enum.max() |> elem(0) |> max(highest)
      {chamber, pi, highest}
    else
      falling(new_rock, chamber, pattern, pi, highest)
    end
  end

  def run(_chamber, target, _pattern, _pi, highest, _cycle, target) do
    highest
  end

  def run(chamber, rock_i, pattern, pi, highest, cycle, target) do
    rock = gen_rock(rock_i, highest)
    {chamber, pi, highest} = falling(rock, chamber, pattern, pi, highest)
    rock_i = rock_i + 1

    if cycle == nil do
      run(chamber, rock_i, pattern, pi, highest, cycle, target)
    else
      topest =
        0..6
        |> Enum.map(fn c ->
          chamber
          |> MapSet.filter(fn {_, y} -> y == c end)
          |> Enum.map(fn {x, _} -> x end)
          |> Enum.max()
        end)

      mi = Enum.min(topest)

      topest = topest |> Enum.map(&(&1 - mi))

      key = {topest, rem(rock_i, 5), pi}

      case cycle[key] do
        {r, h} ->
          cycle_len = rock_i - r
          distance = highest - h
          loops = div(target - rock_i, cycle_len)

          loops * distance +
            run(chamber, rock_i + loops * cycle_len, pattern, pi, highest, nil, target)

        _ ->
          cycle = Map.put(cycle, key, {rock_i, highest})
          run(chamber, rock_i, pattern, pi, highest, cycle, target)
      end
    end
  end

  def input() do
    File.read!("./input.txt")
    |> String.trim()
    |> String.graphemes()
    |> Enum.map(fn c -> if c == "<", do: -1, else: 1 end)
    |> Enum.with_index()
    |> Enum.map(fn {c, i} -> {i, c} end)
    |> Map.new()
  end
end
