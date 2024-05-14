defmodule Solution do
  defmodule Queue do
    @leaf nil
    def new(), do: @leaf

    defp rank(@leaf), do: 0
    defp rank({r, _, _, _}), do: r

    defp merge(@leaf, t), do: t
    defp merge(t, @leaf), do: t

    defp merge({_, lv, ll, lr} = t1, {_, rv, rl, rr} = t2) do
      if lv <= rv do
        swipe(lv, ll, merge(lr, t2))
      else
        swipe(rv, rl, merge(t1, rr))
      end
    end

    defp swipe(v, left, right) do
      if rank(left) >= rank(right) do
        {rank(right) + 1, v, left, right}
      else
        {rank(left) + 1, v, right, left}
      end
    end

    def push(q, v) do
      merge(q, {1, v, @leaf, @leaf})
    end

    def pop(@leaf), do: nil
    def pop({_, v, @leaf, @leaf}), do: {v, @leaf}
    def pop({_, v, l, r}), do: {v, merge(l, r)}
  end

  def part1() do
    input() |> path(false)
  end

  def part2() do
    input() |> path(true)
  end

  defp input() do
    File.stream!("./input.txt")
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {row, i}, m ->
      row
      |> String.trim()
      |> String.graphemes()
      |> Enum.map(&String.to_integer/1)
      |> Enum.with_index()
      |> Enum.reduce(m, fn {v, j}, m ->
        Map.put(m, {i, j}, v)
      end)
    end)
  end

  defp path(grid, with_ultra) do
    target = grid |> Map.keys() |> Enum.max()

    # {{x, y}, step, {dx, dy}}
    # go down
    start1 = {{0, 0}, 0, {1, 0}}
    # go right
    start2 = {{0, 0}, 0, {0, 1}}

    g_score = %{start1 => 0, start2 => 0}

    Queue.new()
    |> Queue.push({0, start1})
    |> Queue.push({0, start2})
    |> path(grid, g_score, %MapSet{}, target, with_ultra)
  end

  defp path(q, grid, g_score, visited, dest, with_ultra) do
    {{_, curr}, q} = Queue.pop(q)

    {pos, _, _} = curr
    cur_g = g_score[curr]

    cond do
      pos == dest ->
        cur_g

      MapSet.member?(visited, curr) ->
        path(q, grid, g_score, visited, dest, with_ultra)

      true ->
        visited = MapSet.put(visited, curr)

        {q, g_score} =
          neighbors(curr, grid, with_ultra)
          |> Enum.reduce({q, g_score}, fn n, {q, g_score} ->
            {pos, _, _} = n
            g = cur_g + grid[pos]

            if Map.get(g_score, n) == nil or g < Map.get(g_score, n) do
              {Queue.push(q, {g, n}), Map.put(g_score, n, g)}
            else
              {q, g_score}
            end
          end)

        path(q, grid, g_score, visited, dest, with_ultra)
    end
  end

  defp neighbors({{x, y}, step, {dx, dy}}, grid, with_ultra) do
    max_step = if with_ultra, do: 10, else: 3
    # go forward
    lst =
      if step < max_step do
        [{{x + dx, y + dy}, step + 1, {dx, dy}}]
      else
        []
      end

    # turn left or right
    if not with_ultra or step > 3 do
      lft = {-dy, dx}
      rht = {dy, -dx}

      [lft, rht]
      |> Enum.reduce(lst, fn {dx, dy}, acc ->
        [{{x + dx, y + dy}, 1, {dx, dy}} | acc]
      end)
    else
      lst
    end
    |> Enum.filter(fn {pos, _, _} -> grid[pos] != nil end)
  end
end
