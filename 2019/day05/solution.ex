defmodule Solution do
  def part1() do
    input()
    |> run(0, 1)
  end

  def part2() do
    input()
    |> run(0, 5)
  end

  def run(mp, i, arg, outputs \\ []) do
    s = "#{mp[i]}" |> String.pad_leading(5, "0")
    [_, b, c, d, e] = s |> String.graphemes() |> Enum.map(&String.to_integer/1)
    op = d * 10 + e

    i1 = if c == 0, do: mp[mp[i + 1]], else: mp[i + 1]
    i2 = if b == 0, do: mp[mp[i + 2]], else: mp[i + 2]
    out = mp[i + 3]

    case op do
      99 ->
        outputs |> Enum.filter(&(&1 != 0)) |> hd()

      1 ->
        mp |> Map.put(out, i1 + i2) |> run(i + 4, arg, outputs)

      2 ->
        mp |> Map.put(out, i1 * i2) |> run(i + 4, arg, outputs)

      3 ->
        mp |> Map.put(mp[i + 1], arg) |> run(i + 2, arg, outputs)

      4 ->
        mp |> run(i + 2, arg, [i1 | outputs])

      5 ->
        i = if i1 != 0, do: i2, else: i + 3
        run(mp, i, arg, outputs)

      6 ->
        i = if i1 == 0, do: i2, else: i + 3
        run(mp, i, arg, outputs)

      7 ->
        v = if i1 < i2, do: 1, else: 0
        mp |> Map.put(out, v) |> run(i + 4, arg, outputs)

      8 ->
        v = if i1 == i2, do: 1, else: 0
        mp |> Map.put(out, v) |> run(i + 4, arg, outputs)
    end
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Enum.to_list()
    |> hd()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {n, i}, acc ->
      Map.put(acc, i, n)
    end)
  end
end
