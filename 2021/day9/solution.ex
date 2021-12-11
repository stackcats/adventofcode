defmodule Solution do
  def part1() do
    {m, r, c} = input() |> to_map()

    for i <- 0..(r - 1), j <- 0..(c - 1), is_lowest(m, i, j) do
      m[{i, j}] + 1
    end
    |> Enum.sum()
  end

  def part2() do
    {m, r, c} = input() |> to_map()

    for i <- 0..(r - 1), j <- 0..(c - 1), is_lowest(m, i, j) do
      basins(m, i, j, MapSet.new()) |> MapSet.size()
    end
    |> Enum.sort(:desc)
    |> Enum.take(3)
    |> Enum.product()
  end

  defp basins(m, i, j, set) do
    cond do
      m[{i, j}] >= 9 ->
        set

      MapSet.member?(set, {i, j}) ->
        set

      true ->
        set = MapSet.put(set, {i, j})
        set = basins(m, i + 1, j, set)
        set = basins(m, i - 1, j, set)
        set = basins(m, i, j + 1, set)
        set = basins(m, i, j - 1, set)
        set
    end
  end

  defp is_lowest(m, i, j) do
    m[{i, j}] < Map.get(m, {i + 1, j}, 10) &&
      m[{i, j}] < Map.get(m, {i - 1, j}, 10) &&
      m[{i, j}] < Map.get(m, {i, j + 1}, 10) &&
      m[{i, j}] < Map.get(m, {i, j - 1}, 10)
  end

  defp input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.graphemes/1)
    |> Stream.map(fn line -> Enum.map(line, &String.to_integer/1) end)
    |> Enum.to_list()
  end

  defp to_map(lst) do
    r = Enum.count(lst)
    c = lst |> List.first() |> Enum.count()

    m =
      lst
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {row, i}, m ->
        Enum.with_index(row)
        |> Enum.reduce(m, fn {n, j}, m ->
          Map.put(m, {i, j}, n)
        end)
      end)

    {m, r, c}
  end
end
