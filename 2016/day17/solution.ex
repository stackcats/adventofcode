defmodule Solution do
  @len 4
  @target {3, 3}
  @pass "awrkjxxr"
  @init {{0, 0}, @pass}

  def part1() do
    [@init]
    |> :queue.from_list()
    |> bfs(MapSet.new())
    |> String.trim_leading(@pass)
  end

  def part2() do
    dfs(@init, 0)
  end

  def dfs({pos, _}, ct) when pos == @target, do: ct

  def dfs({pos, pass}, ct) do
    for n <- neighbors(pos, pass), reduce: 0 do
      acc -> max(acc, dfs(n, ct + 1))
    end
  end

  def bfs(q, visited) do
    {pos, pass} = :queue.head(q)
    q = :queue.tail(q)

    cond do
      pos == @target ->
        pass

      MapSet.member?(visited, {pos, pass}) ->
        bfs(q, visited)

      true ->
        visited = MapSet.put(visited, {pos, pass})

        neighbors(pos, pass)
        |> Enum.reduce(q, &:queue.in/2)
        |> bfs(visited)
    end
  end

  def neighbors({x, y}, pass) do
    pass
    |> md5()
    |> String.slice(0, 4)
    |> String.graphemes()
    |> Enum.zip([{-1, 0, "U"}, {1, 0, "D"}, {0, -1, "L"}, {0, 1, "R"}])
    |> Enum.reduce([], fn {h, {dx, dy, d}}, acc ->
      nx = x + dx
      ny = y + dy

      if open?(nx, ny, h) do
        [{{nx, ny}, pass <> d} | acc]
      else
        acc
      end
    end)
  end

  def open?(x, y, h) do
    x >= 0 && x < @len && y >= 0 && y < @len && String.contains?("bcdef", h)
  end

  def md5(pass) do
    :crypto.hash(:md5, pass) |> Base.encode16(case: :lower)
  end
end
