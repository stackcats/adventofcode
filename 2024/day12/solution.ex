defmodule Solution do
  defmodule UnionFind do
    def new() do
      %{}
    end

    def find(uf, t) do
      case uf[t] do
        nil ->
          {t, Map.put(uf, t, t)}

        ^t ->
          {t, uf}

        r ->
          {x, uf} = find(uf, r)
          {x, Map.put(uf, t, x)}
      end
    end

    def union(uf, a, b) do
      {ra, uf} = find(uf, a)
      {rb, uf} = find(uf, b)

      if ra == rb do
        uf
      else
        Map.put(uf, ra, rb)
      end
    end
  end

  def part1() do
    run(&perimeter/2)
  end

  def part2() do
    run(&sides/2)
  end

  def run(f) do
    g = input()
    {r, c} = g |> Enum.max_by(fn {k, _} -> k end) |> elem(0)

    uf =
      for i <- 0..r, j <- 0..c, reduce: UnionFind.new() do
        acc ->
          [&up/1, &left/1]
          |> Enum.reduce(acc, fn f, acc ->
            neighbor = f.({i, j})

            if g[{i, j}] == g[neighbor] do
              UnionFind.union(acc, {i, j}, neighbor)
            else
              acc
            end
          end)
      end

    g
    |> Enum.reduce({%{}, uf}, fn {pos, _}, {regions, uf} ->
      {root, uf} = UnionFind.find(uf, pos)
      {Map.update(regions, root, [pos], &[pos | &1]), uf}
    end)
    |> elem(0)
    |> Enum.map(fn {_, region} -> area(region) * f.(region, g) end)
    |> Enum.sum()
  end

  def area(region), do: length(region)

  def perimeter(region, g) do
    region
    |> Enum.map(fn pos ->
      [&up/1, &right/1, &down/1, &left/1]
      |> Enum.count(fn f -> g[pos] != g[f.(pos)] end)
    end)
    |> Enum.sum()
  end

  def sides(region, g) do
    region
    |> Enum.map(fn pos ->
      [
        {&up/1, &left/1, &left_up/1},
        {&down/1, &left/1, &left_down/1},
        {&left/1, &up/1, &left_up/1},
        {&right/1, &up/1, &right_up/1}
      ]
      |> Enum.count(&check_side(pos, g, &1))
    end)
    |> Enum.sum()
  end

  def up({i, j}), do: {i - 1, j}
  def down({i, j}), do: {i + 1, j}
  def left({i, j}), do: {i, j - 1}
  def right({i, j}), do: {i, j + 1}
  def left_up({i, j}), do: {i - 1, j - 1}
  def left_down({i, j}), do: {i + 1, j - 1}
  def right_up({i, j}), do: {i - 1, j + 1}

  def check_side(pos, g, {f1, f2, f3}) do
    g[f1.(pos)] != g[pos] and (g[f2.(pos)] != g[pos] or g[f3.(pos)] == g[pos])
  end

  def input() do
    File.read!("./input.txt")
    |> String.trim()
    |> String.split("\n")
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {row, i}, acc ->
      row
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {c, j}, acc ->
        Map.put(acc, {i, j}, c)
      end)
    end)
  end
end
