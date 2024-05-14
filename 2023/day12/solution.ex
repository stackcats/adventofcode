defmodule Solution do
  def part1() do
    input() |> aux()
  end

  def part2() do
    input(5) |> aux()
  end

  def aux(stream) do
    stream
    |> Enum.reduce(0, fn {s, r}, acc ->
      dfs(s, r, 0, %{})
      |> elem(0)
      |> then(&(&1 + acc))
    end)
  end

  def input(times \\ 1) do
    File.stream!("./input.txt")
    |> Stream.map(fn s ->
      [h, r] = s |> String.trim() |> String.split(" ")
      h = h |> repeat(times, "?") |> String.graphemes()
      r = r |> repeat(times, ",") |> String.split(",") |> Enum.map(&String.to_integer/1)
      {h, r}
    end)
  end

  def repeat(s, n, sep) do
    s |> List.duplicate(n) |> Enum.join(sep)
  end

  def dfs([], records, damages, mem) do
    case {records, damages} do
      {[], 0} -> {1, mem}
      {[x], x} -> {1, mem}
      _ -> {0, mem}
    end
  end

  def dfs([s | ss] = springs, records, damages, mem) do
    k = {length(springs), length(records), damages}

    if Map.has_key?(mem, k) do
      {mem[k], mem}
    else
      [".", "#"]
      |> Enum.reduce({0, mem}, fn c, {acc, mem} ->
        if c == s || s == "?" do
          {ct, mem} =
            cond do
              c == "." && damages == 0 ->
                dfs(ss, records, 0, mem)

              c == "." && damages > 0 && records != [] && damages == hd(records) ->
                dfs(ss, tl(records), 0, mem)

              c == "#" ->
                dfs(ss, records, damages + 1, mem)

              true ->
                {0, mem}
            end

          {acc + ct, mem}
        else
          {acc, mem}
        end
      end)
      |> then(fn {acc, mem} ->
        {acc, Map.put(mem, k, acc)}
      end)
    end
  end
end
