defmodule Solution do
  def part1() do
    input() |> run(1)
  end

  def part2() do
    input() |> run(2)
  end

  def run(mp, arg, i \\ 0, offset \\ 0) do
    s = "#{mp[i]}" |> String.pad_leading(5, "0")
    [a, b, c, d, e] = s |> String.graphemes() |> Enum.map(&String.to_integer/1)
    op = d * 10 + e

    args = [mp[i + 1] || 0, mp[i + 2] || 0, mp[i + 3] || 0]
    modes = [c, b, a]

    {reads, writes} =
      Enum.zip(args, modes)
      |> Enum.with_index()
      |> Enum.reduce({%{}, %{}}, fn {{arg, mode}, i}, {reads, writes} ->
        {
          Map.put(reads, i, elem({mp[arg], arg, mp[arg + offset]}, mode)),
          Map.put(writes, i, elem({arg, nil, arg + offset}, mode))
        }
      end)

    case op do
      1 ->
        mp |> Map.put(writes[2], reads[0] + reads[1]) |> run(arg, i + 4, offset)

      2 ->
        mp |> Map.put(writes[2], reads[0] * reads[1]) |> run(arg, i + 4, offset)

      3 ->
        mp |> Map.put(writes[0], arg) |> run(arg, i + 2, offset)

      4 ->
        reads[0]

      5 ->
        i = if reads[0] != 0, do: reads[1], else: i + 3
        run(mp, arg, i, offset)

      6 ->
        i = if reads[0] == 0, do: reads[1], else: i + 3
        run(mp, arg, i, offset)

      7 ->
        v = if reads[0] < reads[1], do: 1, else: 0
        mp |> Map.put(writes[2], v) |> run(arg, i + 4, offset)

      8 ->
        v = if reads[0] == reads[1], do: 1, else: 0
        mp |> Map.put(writes[2], v) |> run(arg, i + 4, offset)

      9 ->
        run(mp, arg, i + 2, offset + reads[0])
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
