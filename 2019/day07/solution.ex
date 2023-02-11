defmodule Solution do
  def part1 do
    codes = input()

    [0, 1, 2, 3, 4]
    |> permutations()
    |> Enum.map(fn perm ->
      perm
      |> Enum.reduce(0, fn n, pre_out ->
        case run(codes, 0, [n, pre_out]) do
          {:halt, v} -> v
          {:cont, _, _, v, _} -> v
        end
      end)
    end)
    |> Enum.max()
  end

  def part2 do
    codes = input()

    [5, 6, 7, 8, 9]
    |> permutations()
    |> Enum.map(fn perm ->
      inputs =
        perm
        |> Enum.with_index()
        |> Enum.reduce(%{}, fn {n, i}, acc ->
          arg = if i == 0, do: [n, 0], else: [n]
          Map.put(acc, i, arg)
        end)

      0..4
      |> Enum.reduce(%{}, fn i, acc ->
        Map.put(acc, i, {codes, 0})
      end)
      |> loop(0, inputs)
    end)
    |> Enum.max()
  end

  def loop(amplifiers, i, inputs) do
    {codes, pc} = amplifiers[i]

    case run(codes, pc, inputs[i]) do
      {:halt, v} ->
        v

      {:cont, codes, pc, out, remain_input} ->
        next = rem(i + 1, 5)

        inputs =
          inputs
          |> Map.put(i, remain_input)
          |> Map.update!(next, &(&1 ++ [out]))

        amplifiers
        |> Map.put(i, {codes, pc})
        |> loop(next, inputs)
    end
  end

  def permutations([]), do: [[]]

  def permutations(list),
    do: for(elem <- list, rest <- permutations(list -- [elem]), do: [elem | rest])

  def run(mp, i, arg) do
    s = "#{mp[i]}" |> String.pad_leading(5, "0")
    [_, b, c, d, e] = s |> String.graphemes() |> Enum.map(&String.to_integer/1)
    op = d * 10 + e

    i1 = if c == 0, do: mp[mp[i + 1]], else: mp[i + 1]
    i2 = if b == 0, do: mp[mp[i + 2]], else: mp[i + 2]
    out = mp[i + 3]

    case op do
      99 ->
        {:halt, hd(arg)}

      1 ->
        mp |> Map.put(out, i1 + i2) |> run(i + 4, arg)

      2 ->
        mp |> Map.put(out, i1 * i2) |> run(i + 4, arg)

      3 ->
        mp |> Map.put(mp[i + 1], hd(arg)) |> run(i + 2, tl(arg))

      4 ->
        {:cont, mp, i + 2, i1, arg}

      5 ->
        i = if i1 != 0, do: i2, else: i + 3
        run(mp, i, arg)

      6 ->
        i = if i1 == 0, do: i2, else: i + 3
        run(mp, i, arg)

      7 ->
        v = if i1 < i2, do: 1, else: 0
        mp |> Map.put(out, v) |> run(i + 4, arg)

      8 ->
        v = if i1 == i2, do: 1, else: 0
        mp |> Map.put(out, v) |> run(i + 4, arg)
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
