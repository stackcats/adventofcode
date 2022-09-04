defmodule Solution do
  @target 368_078

  def part1() do
    aux(%{}, 1, @target, {0, 0, :right})
    |> Enum.find(fn {_k, v} -> v == @target end)
    |> then(fn {k, _} -> k end)
    |> manhattan({0, 0})
  end

  def aux(map, i, j, _pos) when i > j, do: map

  def aux(map, i, j, {x, y, d}) do
    map = Map.put(map, {x, y}, i)
    aux(map, i + 1, j, next_pos(map, {x, y, d}))
  end

  def part2() do
    aux2(%{{0, 0} => 1}, @target, {0, 1, :up})
  end

  def aux2(map, j, {x, y, d}) do
    sum = neighbors(map, {x, y})

    if sum >= j do
      sum
    else
      map = Map.put(map, {x, y}, sum)
      aux2(map, j, next_pos(map, {x, y, d}))
    end
  end

  def neighbors(map, {x, y}) do
    for {dx, dy} <- [{-1, -1}, {-1, 0}, {-1, 1}, {0, 1}, {1, 1}, {1, 0}, {1, -1}, {0, -1}],
        reduce: 0 do
      acc -> acc + Map.get(map, {x + dx, y + dy}, 0)
    end
  end

  def next_pos(map, {x, y, d}) do
    cond do
      d == :right && map[{x, y + 1}] == nil -> {x, y + 1, :up}
      d == :right -> {x + 1, y, :right}
      d == :up && map[{x - 1, y}] == nil -> {x - 1, y, :left}
      d == :up -> {x, y + 1, :up}
      d == :left && map[{x, y - 1}] == nil -> {x, y - 1, :down}
      d == :left -> {x - 1, y, :left}
      d == :down && map[{x + 1, y}] == nil -> {x + 1, y, :right}
      d == :down -> {x, y - 1, :down}
    end
  end

  def manhattan({x1, y1}, {x2, y2}) do
    abs(x1 - x2) + abs(y1 - y2)
  end
end
