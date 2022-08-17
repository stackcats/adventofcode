defmodule Solution do
  def part1() do
    input()
    |> aux(100)
    |> Map.values()
    |> Enum.count(&(&1 == "#"))
  end

  def part2() do
    {map, m, n} = input()

    map =
      [{0, 0}, {0, n - 1}, {m - 1, 0}, {m - 1, n - 1}]
      |> Enum.reduce(map, fn pos, map -> Map.put(map, pos, "#") end)

    aux({map, m, n}, 100, true)
    |> Map.values()
    |> Enum.count(&(&1 == "#"))
  end

  def aux(g, ct, check_corner \\ false)
  def aux({map, _m, _n}, 0, _check_corner), do: map

  def aux({map, m, n}, ct, check_corner) do
    corners = MapSet.new([{0, 0}, {0, n - 1}, {m - 1, 0}, {m - 1, n - 1}])

    new_map =
      for i <- 0..(m - 1), j <- 0..(n - 1), reduce: %{} do
        acc ->
          if check_corner && MapSet.member?(corners, {i, j}) do
            Map.put(acc, {i, j}, map[{i, j}])
          else
            neighbors = count_neighbors(map, i, j)

            state =
              if map[{i, j}] == "#" do
                if neighbors == 2 || neighbors == 3, do: "#", else: "."
              else
                if neighbors == 3, do: "#", else: "."
              end

            Map.put(acc, {i, j}, state)
          end
      end

    aux({new_map, m, n}, ct - 1, check_corner)
  end

  def count_neighbors(map, i, j) do
    [
      {i - 1, j - 1},
      {i - 1, j},
      {i - 1, j + 1},
      {i, j - 1},
      {i, j + 1},
      {i + 1, j - 1},
      {i + 1, j},
      {i + 1, j + 1}
    ]
    |> Enum.count(fn pos -> map[pos] == "#" end)
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.graphemes/1)
    |> Enum.to_list()
    |> then(fn mat ->
      map =
        mat
        |> Enum.with_index()
        |> Enum.reduce(%{}, fn {row, i}, map ->
          row
          |> Enum.with_index()
          |> Enum.reduce(map, fn {c, j}, map ->
            Map.put(map, {i, j}, c)
          end)
        end)

      m = length(mat)
      n = length(hd(mat))
      {map, m, n}
    end)
  end
end
