defmodule Solution do
  @favorite 1352

  def part1() do
    bfs1(:queue.from_list([{1, 1, 0}]), MapSet.new(), {31, 39})
  end

  def bfs1(q, visited, target) do
    {x, y, steps} = :queue.head(q)
    q = :queue.tail(q)

    if {x, y} == target do
      steps
    else
      neighbors(x, y, visited)
      |> Enum.reduce(q, fn {nx, ny}, q -> :queue.in({nx, ny, steps + 1}, q) end)
      |> bfs1(MapSet.put(visited, {x, y}), target)
    end
  end

  def part2() do
    bfs2(:queue.from_list([{1, 1, 0}]), MapSet.new(), 50)
    |> MapSet.size()
  end

  def bfs2(q, visited, most_steps) do
    if :queue.is_empty(q) do
      visited
    else
      {x, y, steps} = :queue.head(q)
      q = :queue.tail(q)

      if steps > most_steps do
        bfs2(q, visited, most_steps)
      else
        neighbors(x, y, visited)
        |> Enum.reduce(q, fn {nx, ny}, q -> :queue.in({nx, ny, steps + 1}, q) end)
        |> bfs2(MapSet.put(visited, {x, y}), most_steps)
      end
    end
  end

  def neighbors(x, y, visited) do
    [{-1, 0}, {0, 1}, {1, 0}, {0, -1}]
    |> Enum.reduce([], fn {dx, dy}, acc ->
      nx = x + dx
      ny = y + dy

      cond do
        nx < 0 || ny < 0 -> acc
        MapSet.member?(visited, {nx, ny}) -> acc
        wall?(nx, ny) -> acc
        true -> [{nx, ny} | acc]
      end
    end)
  end

  def wall?(x, y) do
    n = x * x + 3 * x + 2 * x * y + y + y * y + @favorite
    count_1(n) |> odd?()
  end

  def count_1(n), do: count_1(n, 0)
  def count_1(0, x), do: x

  def count_1(n, x) do
    count_1(div(n, 2), x + rem(n, 2))
  end

  def odd?(n), do: rem(n, 2) == 1
end
