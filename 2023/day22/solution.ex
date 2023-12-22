defmodule Solution do
  def part1() do
    run()
  end

  def part2() do
    run(1)
  end

  def run(n \\ 0) do
    input()
    |> fall()
    |> elem(0)
    |> count([], 0, 0)
    |> elem(n)
  end

  def count([], _, saftys, falls) do
    {saftys, falls}
  end

  def count([b | rs], ls, saftys, falls) do
    {_, count_falled} = fall(ls ++ rs)

    if count_falled == 0 do
      count(rs, ls ++ [b], saftys + 1, falls)
    else
      count(rs, ls ++ [b], saftys, falls + count_falled)
    end
  end

  def fall(bricks) do
    st =
      bricks
      |> Enum.reduce(%MapSet{}, fn {_, cubes}, acc ->
        cubes
        |> Enum.reduce(acc, fn component, acc ->
          MapSet.put(acc, component)
        end)
      end)

    fall(bricks, [], st, false, %MapSet{})
  end

  def fall([], bricks, st, falled?, falled_bricks) do
    bricks = Enum.reverse(bricks)

    if falled? do
      fall(bricks, [], st, false, falled_bricks)
    else
      {bricks, MapSet.size(falled_bricks)}
    end
  end

  def fall([{id, b} | bs], bricks, st, falled?, falled_bricks) do
    blocked? =
      Enum.any?(b, fn {x, y, z} ->
        z == 1 || (MapSet.member?(st, {x, y, z - 1}) && {x, y, z - 1} not in b)
      end)

    if blocked? do
      fall(bs, [{id, b} | bricks], st, falled?, falled_bricks)
    else
      nb = b |> Enum.map(fn {x, y, z} -> {x, y, z - 1} end)

      st =
        Enum.zip(b, nb)
        |> Enum.reduce(st, fn {a, b}, acc ->
          acc
          |> MapSet.delete(a)
          |> MapSet.put(b)
        end)

      fall(bs, [{id, nb} | bricks], st, true, MapSet.put(falled_bricks, id))
    end
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(fn s ->
      ~r/(\d+),(\d+),(\d+)~(\d+),(\d+),(\d+)/
      |> Regex.run(s)
      |> tl()
      |> Enum.map(&String.to_integer/1)
      |> then(fn [x1, y1, z1, x2, y2, z2] ->
        cubes =
          cond do
            x1 == x2 && y1 == y2 ->
              z1..z2
              |> Enum.map(fn z -> {x1, y1, z} end)

            x1 == x2 && z1 == z2 ->
              y1..y2
              |> Enum.map(fn y -> {x1, y, z1} end)

            y1 == y2 && z1 == z2 ->
              x1..x2
              |> Enum.map(fn x -> {x, y1, z1} end)
          end

        id = for _ <- 1..8, into: "", do: <<Enum.random(~c"0123456789abcdef")>>
        {id, cubes}
      end)
    end)
    |> Enum.to_list()
  end
end
