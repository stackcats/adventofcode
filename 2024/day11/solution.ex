defmodule Solution do
  def part1() do
    run(25)
  end

  def part2() do
    run(75)
  end

  def run(ct) do
    input()
    |> Enum.reduce({0, %{}}, fn n, {acc, mem} ->
      {m, mem} = dfs(n, ct, mem)
      {acc + m, mem}
    end)
    |> elem(0)
  end

  def dfs(_, 0, mem), do: {1, mem}

  def dfs(n, ct, mem) do
    key = {n, ct}

    if mem[key] != nil do
      {mem[key], mem}
    else
      ct = ct - 1
      digits = Integer.digits(n)

      if length(digits) |> rem(2) == 0 do
        {lft, rht} = Enum.split(digits, div(length(digits), 2))
        {l, mem} = dfs(to_int(lft), ct, mem)
        {r, mem} = dfs(to_int(rht), ct, mem)
        {l + r, Map.put(mem, key, l + r)}
      else
        {m, mem} = dfs((n == 0 && 1) || n * 2024, ct, mem)
        {m, Map.put(mem, key, m)}
      end
    end
  end

  def to_int(xs) do
    Enum.reduce(xs, 0, fn x, n -> n * 10 + x end)
  end

  def input() do
    File.read!("./input.txt")
    |> String.trim()
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
  end
end
