defmodule Solution do
  def part1() do
    args = input()
    dfs(0, 0, 0, args, 9..1, MapSet.new()) |> elem(0)
  end

  def part2() do
    args = input()
    dfs(0, 0, 0, args, 1..9, MapSet.new()) |> elem(0)
  end

  def dfs(z, depth, model_number, args, digits, set) do
    if depth > 13 || MapSet.member?(set, {depth, z}) do
      {nil, set}
    else
      {r, set} =
        Enum.reduce_while(digits, {nil, set}, fn d, {_, set} ->
          {r, set} = proc(z, depth, d, model_number, args, digits, set)

          if r == nil, do: {:cont, {nil, set}}, else: {:halt, {r, set}}
        end)

      if r == nil do
        {nil, MapSet.put(set, {depth, z})}
      else
        {r, set}
      end
    end
  end

  def proc(z, depth, d, model_number, args, digits, set) do
    {zs, xs, ys} = args
    x = rem(z, 26)
    z = div(z, zs[depth])
    x = x + xs[depth]
    x = if x == d, do: 1, else: 0
    x = if x == 0, do: 1, else: 0
    y = 25 * x + 1
    z = z * y
    y = d + ys[depth]
    y = y * x
    z = z + y

    model_number = model_number * 10 + d

    if z == 0 && depth == 13 do
      {model_number, set}
    else
      dfs(z, depth + 1, model_number, args, digits, set)
    end
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.split/1)
    |> Enum.to_list()
    |> Enum.chunk_every(18)
    |> Enum.map(&parse/1)
    |> transpose()
  end

  def parse(lst) do
    [_, _, z] = Enum.at(lst, 4)
    [_, _, x] = Enum.at(lst, 5)
    [_, _, y] = Enum.at(lst, 15)
    [z, x, y] |> Enum.map(&String.to_integer/1)
  end

  def transpose(mat) do
    mat
    |> Enum.with_index()
    |> Enum.reduce({%{}, %{}, %{}}, fn {[z, x, y], i}, {zs, xs, ys} ->
      {Map.put(zs, i, z), Map.put(xs, i, x), Map.put(ys, i, y)}
    end)
  end
end
