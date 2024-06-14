defmodule Solution do
  def part1() do
    {_, beacons} = run()
    MapSet.size(beacons)
  end

  def part2() do
    {scanners, _} = run()

    for s1 <- scanners, s2 <- scanners, reduce: 0 do
      acc -> max(acc, manhatan(s1, s2))
    end
  end

  def run() do
    [h | t] = input()
    run(t, MapSet.new([[0, 0, 0]]), h)
  end

  def run([], scanners, beacons) do
    {scanners, beacons}
  end

  def run([h | t], scanners, beacons) do
    case find_overlap(beacons, h) do
      nil ->
        run(t ++ [h], scanners, beacons)

      {scanner, overlapped} ->
        run(t, MapSet.put(scanners, scanner), MapSet.union(beacons, overlapped))
    end
  end

  def find_overlap(left, right) do
    left
    |> Enum.find_value(fn l ->
      Enum.find_value(0..5, fn facing ->
        Enum.find_value(0..3, fn rot ->
          rotated = right |> MapSet.new(fn r -> face(r, facing) |> rotate(rot) end)

          rotated
          |> Enum.find_value(fn r ->
            diff = minus(l, r)

            transformed = rotated |> MapSet.new(&plus(&1, diff))

            size = transformed |> MapSet.intersection(left) |> MapSet.size()

            if size >= 12, do: {diff, transformed}
          end)
        end)
      end)
    end)
  end

  def plus(a, b) do
    Enum.zip(a, b) |> Enum.map(fn {a, b} -> a + b end)
  end

  def minus(a, b) do
    Enum.zip(a, b) |> Enum.map(fn {a, b} -> a - b end)
  end

  def manhatan(a, b) do
    minus(a, b) |> Enum.map(&abs/1) |> Enum.sum()
  end

  # https://www.reddit.com/r/adventofcode/comments/rjpf7f/comment/hp7tpyf/
  def face([x, y, z], n) do
    case n do
      0 -> [x, y, z]
      1 -> [-x, y, -z]
      2 -> [z, y, -x]
      3 -> [-z, y, x]
      4 -> [x, z, -y]
      5 -> [x, -z, y]
    end
  end

  def rotate([x, y, z], n) do
    case n do
      0 -> [x, y, z]
      1 -> [-y, x, z]
      2 -> [-x, -y, z]
      3 -> [y, -x, z]
    end
  end

  def input() do
    File.read!("input.txt")
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn s ->
      s
      |> String.split("\n", trim: true)
      |> Enum.drop(1)
      |> MapSet.new(fn r ->
        r
        |> String.split(",")
        |> Enum.map(&String.to_integer/1)
      end)
    end)
  end
end
