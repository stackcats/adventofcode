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
    {map, row, col} = input()
    astar({map, row, col}, {0, 0}, {row - 1, col - 1})
  end

  def part2() do
    {map, row, col} = input() |> expand()
    astar({map, row, col}, {0, 0}, {row - 1, col - 1})
  end

  defp input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.graphemes/1)
    |> Stream.map(fn lst -> Enum.map(lst, &String.to_integer/1) end)
    |> Enum.to_list()
    |> to_map()
  end

  defp to_map(lst) do
    row = Enum.count(lst)

    col = lst |> List.first() |> Enum.count()

    map =
      lst
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {row, i}, m ->
        row
        |> Enum.with_index()
        |> Enum.reduce(m, fn {v, j}, m ->
          Map.put(m, {i, j}, v)
        end)
      end)

    {map, row, col}
  end

  defp expand({map, row, col}) do
    map =
      for j <- col..(col * 5 - 1), i <- 0..(row - 1), reduce: map do
        acc ->
          n = Map.get(acc, {i, j - col}) + 1
          n = if n == 10, do: 1, else: n
          Map.put(acc, {i, j}, n)
      end

    col = col * 5

    map =
      for i <- row..(row * 5 - 1), j <- 0..(col - 1), reduce: map do
        acc ->
          n = Map.get(acc, {i - row, j}) + 1
          n = if n == 10, do: 1, else: n
          Map.put(acc, {i, j}, n)
      end

    {map, row * 5, col}
  end

  defp astar(grid, start, dest) do
    q = Queue.new() |> Queue.push({0, start})
    astar(grid, q, %{start => 0}, dest)
  end

  defp astar({map, row, col}, q, g_score, dest) do
    {{_, cur_pos}, q} = Queue.pop(q)

    cur_g = Map.get(g_score, cur_pos)

    if cur_pos == dest do
      cur_g
    else
      {q, g_score} =
        neighbors(cur_pos, row, col)
        |> Enum.reduce({q, g_score}, fn pos, {q, g_score} ->
          g = cur_g + Map.get(map, pos)

          if Map.get(g_score, pos) == nil or g < Map.get(g_score, pos) do
            f = g + h(pos, dest)
            {Queue.push(q, {f, pos}), Map.put(g_score, pos, g)}
          else
            {q, g_score}
          end
        end)

      astar({map, row, col}, q, g_score, dest)
    end
  end

  defp h({x1, y1}, {x2, y2}) do
    abs(x1 - x2) + abs(y1 - y2)
  end

  defp neighbors({x, y}, row, col) do
    [{1, 0}, {0, -1}, {-1, 0}, {0, 1}]
    |> Enum.map(fn {dx, dy} -> {x + dx, y + dy} end)
    |> Enum.filter(fn {x, y} ->
      x >= 0 and x < row and y >= 0 and y < col
    end)
  end
end
