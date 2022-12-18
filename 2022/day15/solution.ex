defmodule Solution do
  def part1() do
    input()
    |> build_map()
    |> Map.get(2_000_000)
    |> Enum.reduce(0, fn [s, e], acc -> acc + e - s end)
  end

  def part2() do
    map = input() |> build_map()

    0..4_000_000
    |> Enum.find(fn i ->
      Map.get(map, i, []) |> length() > 1
    end)
    |> then(fn i ->
      [[_, e] | _] = map[i]
      (e + 1) * 4_000_000 + i
    end)
  end

  def build_map(lst) do
    lst
    |> Enum.reduce(%{}, fn [y1, x1, y2, x2], segs ->
      dis = distance(x1, y1, x2, y2)

      for dx <- -dis..dis, reduce: segs do
        acc ->
          dy = dis - abs(dx)
          seg = [y1 - dy, y1 + dy]
          Map.update(acc, x1 + dx, [seg], &insert(seg, &1))
      end
    end)
  end

  def insert(item, []), do: [item]

  def insert([x1, y1], [[x2, y2] | rs]) do
    cond do
      y1 < x2 - 1 -> [[x1, y1], [x2, y2] | rs]
      x1 > y2 + 1 -> [[x2, y2] | insert([x1, y1], rs)]
      true -> insert([min(x1, x2), max(y1, y2)], rs)
    end
  end

  def distance(x1, y1, x2, y2) do
    abs(x1 - x2) + abs(y1 - y2)
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(fn s ->
      Regex.scan(~r/-?\d+/, s) |> Enum.flat_map(& &1) |> Enum.map(&String.to_integer/1)
    end)
  end
end
