defmodule Solution do
  def part1() do
    {gates, ops} = input()

    Agent.start_link(fn -> %{} end, name: __MODULE__)
    Agent.update(__MODULE__, fn _ -> gates end)

    ops |> Map.keys() |> Enum.each(&dfs(&1, ops))

    Agent.get(__MODULE__, & &1)
    |> Enum.filter(fn {k, _} -> k =~ ~r/^z/ end)
    |> Enum.sort(:desc)
    |> Enum.map(&elem(&1, 1))
    |> Integer.undigits(2)
  end

  def part2() do
    {_, ops} = input()

    0..44
    |> Enum.reduce({[], nil}, fn i, {acc, c} ->
      i = String.pad_leading("#{i}", 2, "0")
      m = find("x#{i}", "y#{i}", "XOR", ops)
      n = find("x#{i}", "y#{i}", "AND", ops)

      if c do
        {m, n, acc} = if find(c, m, "AND", ops), do: {m, n, acc}, else: {n, m, [m, n | acc]}

        r = find(c, m, "AND", ops)
        z = find(c, m, "XOR", ops)

        {z, acc} = if m =~ ~r/^z/, do: {m, [m, z | acc]}, else: {z, acc}

        {n, z, acc} = if n =~ ~r/^z/, do: {z, n, [n, z | acc]}, else: {n, z, acc}

        {r, z, acc} = if r =~ ~r/^z/, do: {z, r, [r, z | acc]}, else: {r, z, acc}

        c = find(r, n, "OR", ops)

        if c =~ ~r/^z/ and c != "z45" do
          {[c, z | acc], z}
        else
          {acc, c}
        end
      else
        {acc, n}
      end
    end)
    |> elem(0)
    |> Enum.sort()
    |> Enum.join(",")
  end

  def find(a, b, op, ops) do
    Enum.find_value(ops, fn {c, v} -> if v in [{a, op, b}, {b, op, a}], do: c end)
  end

  def dfs(x, ops) do
    {a, op, b} = ops[x]
    a = value(a, ops)
    b = value(b, ops)

    case op do
      "AND" -> Bitwise.band(a, b)
      "OR" -> Bitwise.bor(a, b)
      "XOR" -> Bitwise.bxor(a, b)
    end
    |> tap(fn v -> Agent.update(__MODULE__, fn m -> Map.put(m, x, v) end) end)
  end

  def value(x, ops) do
    Agent.get(__MODULE__, fn m -> m[x] end)
    |> case do
      nil -> dfs(x, ops)
      v -> v
    end
  end

  def input() do
    [gates, ops] =
      File.read!("./input.txt")
      |> String.split("\n\n", trim: true)

    gates =
      gates
      |> String.split("\n", trim: true)
      |> Enum.reduce(%{}, fn s, m ->
        [k, v] = String.split(s, ": ")
        Map.put(m, k, String.to_integer(v))
      end)

    ops =
      ops
      |> String.split("\n", trim: true)
      |> Enum.reduce(%{}, fn s, m ->
        [a, op, b, _, c] = String.split(s, " ")
        Map.put(m, c, {a, op, b})
      end)

    {gates, ops}
  end
end
