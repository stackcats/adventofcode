defmodule Solution do
  def part1() do
    {_, row, col} = map = input()
    source = {0, 1}
    target = {row - 1, col - 2}

    bfs(MapSet.new([source]), map, {source, target}, 0)
    |> elem(0)
  end

  def part2() do
    {_, row, col} = map = input()
    source = {0, 1}
    target = {row - 1, col - 2}

    [{source, target}, {target, source}, {source, target}]
    |> Enum.reduce({0, map}, fn {source, target}, {ct, map} ->
      bfs(MapSet.new([source]), map, {source, target}, ct)
    end)
    |> elem(0)
  end

  def move_blizzards({blizzards, row, col}) do
    blizzards
    |> Enum.map(fn {c, lst} ->
      case c do
        ">" ->
          Enum.map(lst, fn {x, y} ->
            if y == col - 2, do: {x, 1}, else: {x, y + 1}
          end)

        "v" ->
          Enum.map(lst, fn {x, y} ->
            if x == row - 2, do: {1, y}, else: {x + 1, y}
          end)

        "<" ->
          Enum.map(lst, fn {x, y} ->
            if y == 1, do: {x, col - 2}, else: {x, y - 1}
          end)

        "^" ->
          Enum.map(lst, fn {x, y} ->
            if x == 1, do: {row - 2, y}, else: {x - 1, y}
          end)
      end
      |> then(fn lst -> {c, lst} end)
    end)
    |> Map.new()
  end

  def bfs(st, {blizzards, row, col}, {source, target}, ct) do
    blizzards = move_blizzards({blizzards, row, col})

    obstacles = blizzards |> Map.values() |> List.flatten() |> MapSet.new()

    res =
      st
      |> Enum.reduce_while(%MapSet{}, fn {x, y}, acc ->
        case move({x, y}, obstacles, row, col, {source, target}) do
          :done -> {:halt, ct}
          st -> {:cont, MapSet.union(acc, st)}
        end
      end)

    if is_number(res) do
      {res + 1, {blizzards, row, col}}
    else
      bfs(res, {blizzards, row, col}, {source, target}, ct + 1)
    end
  end

  def move({x, y}, obstacles, row, col, {source, target}) do
    [{0, 0}, {1, 0}, {-1, 0}, {0, 1}, {0, -1}]
    |> Enum.reduce_while(%MapSet{}, fn {dx, dy}, acc ->
      nx = x + dx
      ny = y + dy
      pos = {nx, ny}

      cond do
        pos == target -> {:halt, :done}
        pos == source -> {:cont, MapSet.put(acc, pos)}
        nx < 1 or nx >= row - 1 -> {:cont, acc}
        ny < 1 or ny >= col - 1 -> {:cont, acc}
        MapSet.member?(obstacles, pos) -> {:cont, acc}
        true -> {:cont, MapSet.put(acc, pos)}
      end
    end)
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.graphemes/1)
    |> Enum.to_list()
    |> to_map()
  end

  def to_map(lst) do
    row = length(lst)
    col = length(hd(lst))

    mp =
      lst
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {row, i}, acc ->
        row
        |> Enum.with_index()
        |> Enum.reduce(acc, fn {c, j}, acc ->
          if Regex.match?(~r/[><v^]/, c) do
            Map.update(acc, c, [{i, j}], &[{i, j} | &1])
          else
            acc
          end
        end)
      end)

    {mp, row, col}
  end
end
