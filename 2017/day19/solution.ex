defmodule Solution do
  def part1() do
    {m, r, c} = input()
    start = find_start({m, r, c})

    route(m, start, {1, 0}, 0, [])
    |> elem(1)
    |> Enum.reverse()
    |> Enum.join()
  end

  def part2() do
    {m, r, c} = input()
    start = find_start({m, r, c})

    route(m, start, {1, 0}, 0, [])
    |> elem(0)
  end

  def route(m, {x, y}, {dx, dy}, ct, path) do
    case m[{x, y}] do
      nil ->
        {ct, path}

      " " ->
        {ct, path}

      "|" ->
        route(m, {x + dx, y + dy}, {dx, dy}, ct + 1, path)

      "-" ->
        route(m, {x + dx, y + dy}, {dx, dy}, ct + 1, path)

      "+" ->
        {dx, dy} = turn_left(m, {x, y}, {dx, dy}) || turn_right(m, {x, y}, {dx, dy})
        route(m, {x + dx, y + dy}, {dx, dy}, ct + 1, path)

      ch ->
        route(m, {x + dx, y + dy}, {dx, dy}, ct + 1, [ch | path])
    end
  end

  def turn_left(m, {x, y}, {dx, dy}) do
    {dx, dy} =
      case {dx, dy} do
        {1, 0} -> {0, 1}
        {0, 1} -> {-1, 0}
        {-1, 0} -> {0, -1}
        {0, -1} -> {1, 0}
      end

    m[{x + dx, y + dy}] && {dx, dy}
  end

  def turn_right(m, {x, y}, {dx, dy}) do
    {dx, dy} =
      case {dx, dy} do
        {1, 0} -> {0, -1}
        {0, -1} -> {-1, 0}
        {-1, 0} -> {0, 1}
        {0, 1} -> {1, 0}
      end

    m[{x + dx, y + dy}] && {dx, dy}
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim(&1, "\n"))
    |> Stream.map(&String.graphemes/1)
    |> Enum.to_list()
    |> to_map()
  end

  def find_start({m, _r, c}) do
    for j <- 0..(c - 1) do
      {0, j}
    end
    |> Enum.find(fn {i, j} ->
      m[{i, j}] == "|"
    end)
  end

  def to_map(lst) do
    r = length(lst)
    c = length(hd(lst))

    lst
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {row, i}, acc ->
      row
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {c, j}, acc ->
        if c != " ", do: Map.put(acc, {i, j}, c), else: acc
      end)
    end)
    |> then(fn m ->
      {m, r, c}
    end)
  end
end
