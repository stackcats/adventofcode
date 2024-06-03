defmodule Solution do
  def part1() do
    run()
  end

  def part2() do
    run(4)
  end

  def run(dim \\ 3) do
    points = input(dim)

    1..6
    |> Enum.reduce(points, fn _, acc -> cycle(acc) end)
    |> Enum.count(fn {_, state} -> state end)
  end

  def cycle(points) do
    ext_points =
      points
      |> Enum.reduce(points, fn {p, _}, acc ->
        neighbors(p) |> Enum.reduce(acc, &Map.put_new(&2, &1, false))
      end)

    ext_points
    |> Enum.reduce(%{}, fn {p, state}, acc ->
      ct = neighbors(p) |> Enum.count(fn p -> ext_points[p] end)
      Map.put(acc, p, (state && ct in 2..3) || ct == 3)
    end)
  end

  def neighbors({x, y, z}) do
    for dx <- -1..1, dy <- -1..1, dz <- -1..1, {dx, dy, dz} != {0, 0, 0} do
      {x + dx, y + dy, z + dz}
    end
  end

  def neighbors({x, y, z, w}) do
    for dx <- -1..1, dy <- -1..1, dz <- -1..1, dw <- -1..1, {dx, dy, dz, dw} != {0, 0, 0, 0} do
      {x + dx, y + dy, z + dz, w + dw}
    end
  end

  def input(dim \\ 3) do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.with_index()
    |> Enum.reduce(%{}, fn {s, i}, acc ->
      s
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {c, j}, acc ->
        p = if dim == 3, do: {i, j, 0}, else: {i, j, 0, 0}
        Map.put(acc, p, c == "#")
      end)
    end)
  end
end
