defmodule Solution do
  def part1() do
    asteroids = input()

    asteroids
    |> Stream.map(fn p1 ->
      scan_count(asteroids, p1)
      |> MapSet.size()
    end)
    |> Enum.max()
  end

  def part2() do
    asteroids = input()

    base =
      asteroids
      |> Enum.max_by(fn p1 ->
        scan_count(asteroids, p1)
      end)

    asteroids
    |> MapSet.delete(base)
    |> Enum.reduce(%{}, fn p, acc ->
      ang = angle(base, p)
      dis = distance(base, p)
      item = {dis, p}

      Map.update(acc, ang, [item], &[item | &1])
    end)
    |> Map.new(fn {ang, v} -> {ang, Enum.sort(v)} end)
    |> Enum.sort_by(fn {ang, _} -> ang end)
    |> Enum.flat_map(fn {ang, v} ->
      v
      |> Enum.with_index()
      |> Enum.map(fn {{_, p}, layer} -> {layer, ang, p} end)
    end)
    |> Enum.sort()
    |> Enum.at(199)
    |> elem(2)
    |> then(fn {x, y} -> x * 100 + y end)
  end

  def scan_count(asteroids, p1) do
    asteroids
    |> MapSet.delete(p1)
    |> Enum.reduce(%MapSet{}, fn p2, acc ->
      MapSet.put(acc, angle(p2, p1))
    end)
  end

  def distance({x1, y1}, {x2, y2}) do
    ((y1 - y2) ** 2 + (x1 - x2) ** 2) ** 0.5
  end

  def angle({x1, y1}, {x2, y2}) do
    ang = :math.atan2(y2 - y1, x2 - x1) * 180 / :math.pi() + 90

    if ang < 0, do: 360 + ang, else: ang
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Enum.with_index()
    |> Enum.reduce(%MapSet{}, fn {row, y}, acc ->
      row
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {c, x}, acc ->
        if c == "#" do
          MapSet.put(acc, {x, y})
        else
          acc
        end
      end)
    end)
  end
end
