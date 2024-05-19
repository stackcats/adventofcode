defmodule Solution do
  def part1() do
    robots = input()
    [x, y, z, r] = Enum.max_by(robots, fn [_, _, _, r] -> r end)

    robots
    |> Enum.count(fn [a, b, c, _] ->
      abs(x - a) + abs(y - b) + abs(z - c) <= r
    end)
  end

  def part2() do
    input()
    |> Enum.reduce(:gb_sets.empty(), fn [a, b, c, r], acc ->
      dis = abs(a) + abs(b) + abs(c)
      acc = :gb_sets.add({max(dis - r, 0), 1}, acc)
      :gb_sets.add({dis + r + 1, -1}, acc)
    end)
    |> :gb_sets.to_list()
    |> Enum.reduce({0, 0, 0}, fn {dis, n}, {max_dis, ct, max_ct} ->
      ct = ct + n

      if ct > max_ct do
        {dis, ct, ct}
      else
        {max_dis, ct, max_ct}
      end
    end)
    |> elem(0)
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(fn s ->
      Regex.scan(~r/-?\d+/, s)
      |> Enum.map(fn [each] -> String.to_integer(each) end)
    end)
    |> Enum.to_list()
  end
end
