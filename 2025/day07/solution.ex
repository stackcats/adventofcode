defmodule Solution do
  def part1() do
    {mp, beam} = input()
    max_row = Enum.max(mp) |> elem(0)
    state = {[beam], %MapSet{}, %MapSet{}}
    bfs(state, mp, max_row)
  end

  def part2() do
    {mp, beam} = input()
    max_row = Enum.max(mp) |> elem(0)
    dfs(beam, mp, max_row, %{}) |> elem(0)
  end

  def dfs({i, j}, mp, max_row, memo) do
    case Map.get(memo, {i, j}) do
      nil ->
        if i > max_row do
          {1, memo}
        else
          i = i + 1

          if {i, j} in mp do
            {l, memo} = dfs({i, j - 1}, mp, max_row, memo)
            {r, memo} = dfs({i, j + 1}, mp, max_row, memo)
            Map.put(memo, {i, j}, l + r)
            {l + r, memo}
          else
            {v, memo} = dfs({i, j}, mp, max_row, memo)
            {v, Map.put(memo, {i, j}, v)}
          end
        end

      v ->
        {v, memo}
    end
  end

  def bfs({[], _memo, splitters}, _mp, _max_row), do: MapSet.size(splitters)

  def bfs({beams, memo, splitters}, mp, max_row) do
    beams
    |> Enum.reduce({[], memo, splitters}, fn {i, j}, {beams, memo, splitters} = acc ->
      i = i + 1
      pos = {i, j}

      if pos in memo do
        acc
      else
        memo = MapSet.put(memo, pos)

        cond do
          i > max_row ->
            {beams, memo, splitters}

          pos in mp ->
            {[{i, j - 1}, {i, j + 1} | beams], memo, MapSet.put(splitters, pos)}

          true ->
            {[pos | beams], memo, splitters}
        end
      end
    end)
    |> bfs(mp, max_row)
  end

  def input() do
    File.read!("./input.txt")
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.reduce({%MapSet{}, {}}, fn {s, i}, acc ->
      s
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {c, j}, {mp, beam} ->
        case c do
          "S" -> {mp, {i, j}}
          "^" -> {MapSet.put(mp, {i, j}), beam}
          _ -> {mp, beam}
        end
      end)
    end)
  end
end
