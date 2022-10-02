defmodule Solution do
  def part1() do
    input()
    |> aux(0)
    |> elem(1)
  end

  def aux([], ans), do: {[], ans}

  def aux([nodes, metas | xs], ans) do
    for _ <- 1..nodes//1, reduce: {xs, ans} do
      {xs, ans} -> aux(xs, ans)
    end
    |> then(fn {xs, ans} ->
      {f, r} = Enum.split(xs, metas)
      {r, ans + Enum.sum(f)}
    end)
  end

  def part2() do
    input()
    |> aux2()
    |> elem(1)
  end

  def aux2([]), do: 0

  def aux2([nodes, metas | xs]) do
    if nodes == 0 do
      {f, r} = Enum.split(xs, metas)
      {r, Enum.sum(f)}
    else
      for _ <- 1..nodes//1, reduce: {xs, []} do
        {xs, child_values} ->
          {xs, value} = aux2(xs)
          {xs, child_values ++ [value]}
      end
      |> then(fn {xs, child_values} ->
        {f, r} = Enum.split(xs, metas)
        value = f |> Enum.map(&Enum.at(child_values, &1 - 1, 0)) |> Enum.sum()
        {r, value}
      end)
    end
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Enum.to_list()
    |> hd()
    |> String.split()
    |> Enum.map(&String.to_integer/1)
  end
end
