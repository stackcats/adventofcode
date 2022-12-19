defmodule Solution do
  @offsets [[1, 0, 0], [0, 1, 0], [0, 0, 1], [-1, 0, 0], [0, -1, 0], [0, 0, -1]]

  def part1() do
    cubes = input()

    cubes
    |> Enum.flat_map(&neighbours/1)
    |> Enum.count(fn pos -> pos not in cubes end)
  end

  def part2() do
    cubes = input()
    bbox = bounds(cubes)

    surfaces =
      :queue.from_list([[0, 0, 0]])
      |> bfs(cubes, %MapSet{}, bbox)

    cubes
    |> Enum.flat_map(&neighbours/1)
    |> Enum.count(&MapSet.member?(surfaces, &1))
  end

  def bfs(q, cubes, ans, bbox) do
    if :queue.is_empty(q) do
      ans
    else
      curr = :queue.head(q)
      q = :queue.tail(q)

      if curr in cubes do
        bfs(q, cubes, ans, bbox)
      else
        cubes = MapSet.put(cubes, curr)

        curr
        |> neighbours()
        |> Enum.reduce({q, ans}, fn pos, {q, ans} ->
          if pos in cubes || not in_bound(pos, bbox) do
            {q, ans}
          else
            {:queue.in(pos, q), MapSet.put(ans, pos)}
          end
        end)
        |> then(fn {q, ans} -> bfs(q, cubes, ans, bbox) end)
      end
    end
  end

  def in_bound(pos, bbox) do
    Enum.zip(pos, bbox)
    |> Enum.all?(fn {v, {mi, ma}} -> v >= mi - 1 && v <= ma + 1 end)
  end

  def bounds(cubes) do
    mi = [1000, 1000, 1000]
    ma = [0, 0, 0]

    cubes
    |> Enum.reduce([mi, ma], fn pos, [mi, ma] ->
      [
        Enum.zip(pos, mi) |> Enum.map(fn {v1, v2} -> min(v1, v2) end),
        Enum.zip(pos, ma) |> Enum.map(fn {v1, v2} -> max(v1, v2) end)
      ]
    end)
    |> Enum.zip()
  end

  def neighbours(cube) do
    @offsets
    |> Enum.reduce(%MapSet{}, fn offset, acc ->
      pos = Enum.zip(offset, cube) |> Enum.map(&Tuple.sum/1)
      MapSet.put(acc, pos)
    end)
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(fn s ->
      s
      |> String.trim()
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)
    end)
    |> MapSet.new()
  end
end
