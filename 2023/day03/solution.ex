defmodule Solution do
  def part1() do
    input()
    |> parse_numbers()
    |> Map.values()
    |> Enum.reduce(0, fn {v, b}, acc ->
      if MapSet.size(b) > 0 do
        acc + v
      else
        acc
      end
    end)
  end

  def part2() do
    {mp, row, col} = input()

    parse_numbers({mp, row, col})
    |> Map.values()
    |> Enum.reduce(%{}, fn {v, bs}, acc ->
      bs
      |> Enum.reduce(acc, fn b, acc ->
        Map.update(acc, b, [v], &[v | &1])
      end)
    end)
    |> Enum.filter(fn {k, v} ->
      mp[k] == "*" && length(v) > 1
    end)
    |> Enum.reduce(0, fn {_, v}, acc -> acc + Enum.product(v) end)
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.graphemes/1)
    |> Enum.to_list()
    |> to_map()
  end

  def to_map(mat) do
    mp =
      mat
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {row, r}, acc ->
        Enum.with_index(row)
        |> Enum.reduce(acc, fn {v, c}, acc ->
          Map.put(acc, {r, c}, v)
        end)
      end)

    row = length(mat)
    col = length(hd(mat))
    {mp, row, col}
  end

  def parse_numbers({map, row, col}) do
    for i <- 0..(row - 1), j <- 0..(col - 1), reduce: %{} do
      acc ->
        sym = map[{i, j}]

        if Regex.match?(~r/[0-9]/, sym) do
          root = find_root(map, i, j)
          n = String.to_integer(sym)
          border = borders(map, i, j)

          Map.update(acc, root, {n, border}, fn {v, b} ->
            {v * 10 + n, MapSet.union(b, border)}
          end)
        else
          acc
        end
    end
  end

  def find_root(map, i, j) do
    if Regex.match?(~r/[0-9]/, Map.get(map, {i, j - 1}, "")) do
      find_root(map, i, j - 1)
    else
      {i, j}
    end
  end

  def borders(map, i, j) do
    for di <- [-1, 0, 1], dj <- [-1, 0, 1] do
      {i + di, j + dj}
    end
    |> Enum.filter(fn v ->
      sym = Map.get(map, v, "")
      Regex.match?(~r/[^0-9.]/, sym)
    end)
    |> MapSet.new()
  end
end
