defmodule Solution do
  def part1() do
    m = input()
    bottom = m |> Enum.max_by(fn {{i, _}, _} -> i end) |> elem(0) |> elem(0)

    flow(m, bottom)
    |> Enum.count(fn {_, c} -> c == "o" end)
  end

  def part2() do
    m = input()
    bottom = m |> Enum.max_by(fn {{i, _}, _} -> i end) |> elem(0) |> elem(0)

    flow(m, bottom + 1, true)
    |> Enum.count(fn {_, c} -> c == "o" end)
  end

  def flow(m, bottom, has_floor? \\ false) do
    if m[{0, 500}] == "o" do
      m
    else
      case fall(m, {0, 500}, bottom, has_floor?) do
        {:stop, m} ->
          m

        {:ok, m} ->
          flow(m, bottom, has_floor?)
      end
    end
  end

  def fall(m, {i, j}, bottom, has_floor?) do
    cond do
      i >= bottom ->
        if has_floor? do
          {:ok, Map.put(m, {i, j}, "o")}
        else
          {:stop, m}
        end

      m[{i + 1, j}] == nil ->
        fall(m, {i + 1, j}, bottom, has_floor?)

      m[{i + 1, j - 1}] == nil ->
        fall(m, {i + 1, j - 1}, bottom, has_floor?)

      m[{i + 1, j + 1}] == nil ->
        fall(m, {i + 1, j + 1}, bottom, has_floor?)

      true ->
        {:ok, Map.put(m, {i, j}, "o")}
    end
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(fn s ->
      s
      |> String.split(" -> ")
      |> Enum.map(fn s ->
        s
        |> String.split(",")
        |> Enum.map(&String.to_integer/1)
      end)
    end)
    |> Enum.to_list()
    |> to_map()
  end

  def to_map(lst) do
    lst
    |> Enum.reduce(%{}, fn row, acc ->
      row
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.reduce(acc, fn [[x1, y1], [x2, y2]], acc ->
        for x <- x1..x2, y <- y1..y2, reduce: acc do
          acc -> Map.put(acc, {y, x}, "#")
        end
      end)
    end)
  end
end
