defmodule Solution do
  def part1() do
    input()
    |> find_target()
    |> length()
    |> div(2)
  end

  def part2() do
    mp = input()
    {row, col} = mp |> Map.keys() |> Enum.max()

    loop =
      mp
      |> find_target()
      |> MapSet.new()

    0..row
    |> Enum.reduce(0, fn i, ans ->
      0..col
      |> Enum.reduce({ans, 0}, fn j, {ans, ct} ->
        cond do
          not MapSet.member?(loop, {i, j}) ->
            {ans + rem(ct, 2), ct}

          String.contains?("|LJ", mp[{i, j}]) ->
            {ans, ct + 1}

          true ->
            {ans, ct}
        end
      end)
      |> elem(0)
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
    lst
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {row, i}, acc ->
      row
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {c, j}, acc ->
        Map.put(acc, {i, j}, c)
      end)
    end)
  end

  def find_start(mp) do
    mp
    |> Enum.find(fn {_, v} -> v == "S" end)
    |> elem(0)
  end

  def find_target(mp) do
    {x, y} = find_start(mp)

    [{1, 0}, {0, -1}, {-1, 0}, {0, 1}]
    |> Enum.map(fn {dx, dy} ->
      find_loop({x + dx, y + dy}, {dx, dy}, mp, [{x, y}])
    end)
    |> Enum.find(&(&1 != []))
  end

  def find_loop({x, y} = pos, {dx, dy}, mp, routes) do
    curr = mp[pos]

    if curr == "S" do
      routes
    else
      {dx, dy} =
        cond do
          curr == "|" && {dx, dy} == {1, 0} -> {dx, dy}
          curr == "|" && {dx, dy} == {-1, 0} -> {dx, dy}
          curr == "-" && {dx, dy} == {0, 1} -> {dx, dy}
          curr == "-" && {dx, dy} == {0, -1} -> {dx, dy}
          curr == "L" && {dx, dy} == {1, 0} -> {0, 1}
          curr == "L" && {dx, dy} == {0, -1} -> {-1, 0}
          curr == "J" && {dx, dy} == {1, 0} -> {0, -1}
          curr == "J" && {dx, dy} == {0, 1} -> {-1, 0}
          curr == "7" && {dx, dy} == {0, 1} -> {1, 0}
          curr == "7" && {dx, dy} == {-1, 0} -> {0, -1}
          curr == "F" && {dx, dy} == {-1, 0} -> {0, 1}
          curr == "F" && {dx, dy} == {0, -1} -> {1, 0}
          true -> {nil, nil}
        end

      if dx == nil do
        []
      else
        find_loop({x + dx, y + dy}, {dx, dy}, mp, [pos | routes])
      end
    end
  end
end
