defmodule Solution do
  def part1() do
    mp = input()

    ws = String.graphemes("XMAS")

    mp
    |> Enum.map(fn {p, _c} ->
      [{-1, -1}, {-1, 0}, {-1, 1}, {0, 1}, {1, 1}, {1, 0}, {1, -1}, {0, -1}]
      |> Enum.count(&check(mp, p, &1, ws))
    end)
    |> Enum.sum()
  end

  def part2() do
    mp = input()

    mp
    |> Enum.count(fn
      {p, "A"} -> check_x(mp, p)
      _ -> false
    end)
  end

  def check_x(mp, {x, y}) do
    [[{-1, -1}, {1, 1}], [{-1, 1}, {1, -1}]]
    |> Enum.all?(fn ds ->
      ds
      |> Enum.map(fn {dx, dy} -> Map.get(mp, {x + dx, y + dy}, "") end)
      |> Enum.join("")
      |> then(&(&1 in ["SM", "MS"]))
    end)
  end

  defp check(_, _, _, []), do: true

  defp check(mp, curr = {x, y}, d = {dx, dy}, [w | ws]) do
    if mp[curr] != w do
      false
    else
      check(mp, {x + dx, y + dy}, d, ws)
    end
  end

  def input() do
    File.read!("./input.txt")
    |> String.split("\n")
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {r, i}, acc ->
      r
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {c, j}, acc ->
        Map.put(acc, {i, j}, c)
      end)
    end)
  end
end
