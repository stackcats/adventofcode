defmodule Solution do
  @cycles 1_000_000_000

  def part1() do
    input()
    |> north()
    |> string()
    |> calc_load()
  end

  def part2() do
    {loop_start, cache} = input() |> loop()

    size = map_size(cache)
    target = rem(@cycles - loop_start, size - loop_start - 1) + loop_start

    cache
    |> Enum.find(fn {_, v} -> v == target end)
    |> elem(0)
    |> calc_load()
  end

  def calc_load(s) do
    s
    |> String.split("\n")
    |> Enum.reverse()
    |> Enum.with_index()
    |> Enum.map(fn {r, i} ->
      r
      |> String.graphemes()
      |> Enum.count(fn c -> c == "O" end)
      |> then(fn ct -> ct * (i + 1) end)
    end)
    |> Enum.sum()
  end

  def loop(mp) do
    1..@cycles
    |> Enum.reduce_while({mp, %{}}, fn i, {acc, cache} ->
      s = string(acc)

      if cache[s] != nil do
        {:halt, {cache[s], cache}}
      else
        {:cont, {circle(acc), Map.put(cache, s, i)}}
      end
    end)
  end

  def circle(mp) do
    mp
    |> north()
    |> west()
    |> south()
    |> east()
  end

  def north({mp, row, col}) do
    top =
      for j <- 0..col, reduce: %{} do
        acc ->
          Map.put(acc, j, 0)
      end

    for i <- 0..row, j <- 0..col, reduce: {mp, top} do
      {mp, top} ->
        case mp[{i, j}] do
          "#" ->
            {mp, Map.put(top, j, i + 1)}

          "O" ->
            t = top[j]

            mp =
              mp
              |> Map.put({i, j}, ".")
              |> Map.put({t, j}, "O")

            {mp, Map.put(top, j, t + 1)}

          "." ->
            {mp, top}
        end
    end
    |> then(fn {mp, _} -> {mp, row, col} end)
  end

  def west({mp, row, col}) do
    left =
      for i <- 0..row, reduce: %{} do
        acc ->
          Map.put(acc, i, 0)
      end

    for j <- 0..col, i <- 0..row, reduce: {mp, left} do
      {mp, left} ->
        case mp[{i, j}] do
          "#" ->
            {mp, Map.put(left, i, j + 1)}

          "O" ->
            t = left[i]

            mp =
              mp
              |> Map.put({i, j}, ".")
              |> Map.put({i, t}, "O")

            {mp, Map.put(left, i, t + 1)}

          "." ->
            {mp, left}
        end
    end
    |> then(fn {mp, _} -> {mp, row, col} end)
  end

  def south({mp, row, col}) do
    bottom =
      for j <- 0..col, reduce: %{} do
        acc ->
          Map.put(acc, j, row)
      end

    for i <- row..0, j <- 0..col, reduce: {mp, bottom} do
      {mp, bottom} ->
        case mp[{i, j}] do
          "#" ->
            {mp, Map.put(bottom, j, i - 1)}

          "O" ->
            t = bottom[j]

            mp =
              mp
              |> Map.put({i, j}, ".")
              |> Map.put({t, j}, "O")

            {mp, Map.put(bottom, j, t - 1)}

          "." ->
            {mp, bottom}
        end
    end
    |> then(fn {mp, _} -> {mp, row, col} end)
  end

  def east({mp, row, col}) do
    right =
      for i <- 0..row, reduce: %{} do
        acc ->
          Map.put(acc, i, col)
      end

    for j <- col..0, i <- 0..row, reduce: {mp, right} do
      {mp, right} ->
        case mp[{i, j}] do
          "#" ->
            {mp, Map.put(right, i, j - 1)}

          "O" ->
            t = right[i]

            mp =
              mp
              |> Map.put({i, j}, ".")
              |> Map.put({i, t}, "O")

            {mp, Map.put(right, i, t - 1)}

          "." ->
            {mp, right}
        end
    end
    |> then(fn {mp, _} -> {mp, row, col} end)
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.graphemes/1)
    |> to_map()
  end

  def to_map(sm) do
    mp =
      sm
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {row, i}, acc ->
        row
        |> Enum.with_index()
        |> Enum.reduce(acc, fn {c, j}, acc ->
          Map.put(acc, {i, j}, c)
        end)
      end)

    {row, col} = mp |> Map.keys() |> Enum.max()
    {mp, row, col}
  end

  def string({mp, row, col}) do
    for i <- 0..row do
      for j <- 0..col do
        mp[{i, j}]
      end
      |> Enum.join("")
    end
    |> Enum.join("\n")
  end
end
