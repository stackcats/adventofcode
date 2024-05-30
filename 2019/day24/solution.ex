defmodule Solution do
  @center {2, 2}

  def part1() do
    g = input() |> run(%MapSet{})

    1..25
    |> Enum.reduce(0, fn n, acc ->
      i = div(n - 1, 5)
      j = rem(n - 1, 5)
      if g[{i, j}] == "#", do: 2 ** (n - 1) + acc, else: acc
    end)
  end

  def part2() do
    gs = %{0 => input()}

    1..200
    |> Enum.reduce(gs, fn _, acc -> run_with_level(acc) end)
    |> Enum.reduce(0, fn {_, g}, acc ->
      g |> Map.values() |> Enum.count(&(&1 == "#")) |> then(&(&1 + acc))
    end)
  end

  def run_with_level(gs) do
    {mi, ma} = gs |> Map.keys() |> Enum.min_max()

    for level <- (mi - 1)..(ma + 1), reduce: %{} do
      acc ->
        Map.put(acc, level, next_with_level(gs, level))
    end
  end

  def next_with_level(gs, level) do
    for i <- 0..4, j <- 0..4, reduce: %{} do
      acc ->
        p = {i, j}

        bugs =
          adjacent(p, level)
          |> Enum.count(fn {p, level} -> get(gs, level, p) == "#" end)

        cell = get(gs, level, p)

        cond do
          cell == "#" and bugs != 1 -> Map.put(acc, p, ".")
          cell == "." and bugs in [1, 2] -> Map.put(acc, p, "#")
          true -> Map.put(acc, p, cell)
        end
    end
  end

  def north({x, y}), do: {x - 1, y}
  def south({x, y}), do: {x + 1, y}
  def west({x, y}), do: {x, y - 1}
  def east({x, y}), do: {x, y + 1}

  def adjacent(@center, _), do: []

  def adjacent(p, level) do
    [
      add_north(p, level),
      add_east(p, level),
      add_south(p, level),
      add_west(p, level)
    ]
    |> List.flatten()
  end

  def add_north({x, y} = p, level) do
    cond do
      p == south(@center) -> 0..4 |> Enum.map(fn j -> {{4, j}, level + 1} end)
      x == 0 -> {north(@center), level - 1}
      true -> {north(p), level}
    end
  end

  def add_east({x, y} = p, level) do
    cond do
      p == west(@center) -> 0..4 |> Enum.map(fn i -> {{i, 0}, level + 1} end)
      y == 4 -> {east(@center), level - 1}
      true -> {east(p), level}
    end
  end

  def add_south({x, y} = p, level) do
    cond do
      p == north(@center) -> 0..4 |> Enum.map(fn j -> {{0, j}, level + 1} end)
      x == 4 -> {south(@center), level - 1}
      true -> {south(p), level}
    end
  end

  def add_west({x, y} = p, level) do
    cond do
      p == east(@center) -> 0..4 |> Enum.map(fn i -> {{i, 4}, level + 1} end)
      y == 0 -> {west(@center), level - 1}
      true -> {west(p), level}
    end
  end

  def get(gs, level, p) do
    gs |> Map.get(level, %{}) |> Map.get(p, ".")
  end

  def run(g, seen) do
    if g in seen do
      g
    else
      next(g)
      |> run(MapSet.put(seen, g))
    end
  end

  def next(g) do
    for i <- 0..4, j <- 0..4, reduce: %{} do
      acc ->
        bugs =
          [{-1, 0}, {0, 1}, {1, 0}, {0, -1}]
          |> Enum.count(fn {di, dj} -> g[{di + i, dj + j}] == "#" end)

        cond do
          g[{i, j}] == "#" and bugs != 1 -> Map.put(acc, {i, j}, ".")
          g[{i, j}] == "." and bugs in [1, 2] -> Map.put(acc, {i, j}, "#")
          true -> Map.put(acc, {i, j}, g[{i, j}])
        end
    end
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.with_index()
    |> Enum.reduce(%{}, fn {s, i}, acc ->
      s
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {c, j}, acc ->
        Map.put(acc, {i, j}, c)
      end)
    end)
  end
end
