defmodule Solution do
  defmodule Grid do
    defstruct [:map, :r, :c]

    def new(lst) do
      r = Enum.count(lst)
      c = Enum.count(hd(lst))

      map =
        Enum.with_index(lst)
        |> Enum.reduce(%{}, fn {row, i}, m ->
          Enum.with_index(row)
          |> Enum.reduce(m, fn {n, j}, m ->
            Map.put(m, {i, j}, n)
          end)
        end)

      %Grid{map: map, r: r, c: c}
    end
  end

  def part1() do
    input()
    |> move()
  end

  def part2() do
  end

  def move(g) do
    move(g, 0)
  end

  def move(g, ct) do
    {east_moved, g} = move_to_east(g)
    {south_moved, g} = move_to_south(g)

    if east_moved || south_moved do
      move(g, ct + 1)
    else
      ct + 1
    end
  end

  def move_to_south(g) do
    for j <- 0..(g.c - 1), reduce: {false, g} do
      {moved, g} -> move_column(g, j, moved)
    end
  end

  def move_column(g, j, moved) do
    move_column(g, {0, j}, MapSet.new(), moved)
  end

  def move_column(g, {i, _j}, _s, moved) when i >= g.r do
    {moved, g}
  end

  def move_column(g, {i, j}, s, moved) do
    k = if i == 0, do: g.r - 1, else: i - 1

    cond do
      MapSet.member?(s, i) || MapSet.member?(s, k) ->
        move_column(g, {i + 1, j}, s, moved)

      Map.get(g.map, {i, j}) == "." && Map.get(g.map, {k, j}) == "v" ->
        s = s |> MapSet.put(i) |> MapSet.put(k)
        map = g.map |> Map.put({i, j}, "v") |> Map.put({k, j}, ".")
        move_column(%Grid{g | map: map}, {i + 1, j}, s, true)

      true ->
        move_column(g, {i + 1, j}, s, moved)
    end
  end

  def move_to_east(g) do
    for i <- 0..(g.r - 1), reduce: {false, g} do
      {moved, g} -> move_row(g, i, moved)
    end
  end

  def move_row(g, i, moved) do
    move_row(g, {i, 0}, MapSet.new(), moved)
  end

  def move_row(g, {_i, j}, _s, moved) when j >= g.c do
    {moved, g}
  end

  def move_row(g, {i, j}, s, moved) do
    k = if j == 0, do: g.c - 1, else: j - 1

    cond do
      MapSet.member?(s, j) || MapSet.member?(s, k) ->
        move_row(g, {i, j + 1}, s, moved)

      Map.get(g.map, {i, j}) == "." && Map.get(g.map, {i, k}) == ">" ->
        s = s |> MapSet.put(j) |> MapSet.put(k)
        map = g.map |> Map.put({i, j}, ">") |> Map.put({i, k}, ".")
        move_row(%Grid{g | map: map}, {i, j + 1}, s, true)

      true ->
        move_row(g, {i, j + 1}, s, moved)
    end
  end

  def input() do
    File.stream!('./input.txt')
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.graphemes/1)
    |> Enum.to_list()
    |> Grid.new()
  end
end
