defmodule Solution do
  def part1() do
    {ip, ins} = input()
    rs = 0..5 |> Map.new(fn n -> {n, 0} end)
    run(ip, ins, rs)
  end

  def part2() do
    {ip, ins} = input()
    rs = 0..5 |> Map.new(fn n -> {n, 0} end)
    run(ip, ins, rs, 0, %MapSet{}, true)
  end

  def run({r, i}, ins, rs, prev \\ nil, seen \\ %MapSet{}, upper_bound? \\ false) do
    rs = Map.put(rs, r, i) |> doit(ins[i])
    i = rs[r] + 1

    case ins[i] do
      {"eqrr", n, 0, _} ->
        x = rs[n]

        cond do
          upper_bound? and not MapSet.member?(seen, x) ->
            run({r, i}, ins, rs, x, MapSet.put(seen, x), upper_bound?)

          upper_bound? ->
            prev

          true ->
            x
        end

      _ ->
        run({r, i}, ins, rs, prev, seen, upper_bound?)
    end
  end

  def doit(rs, ins) do
    {op, a, b, c} = ins

    case op do
      "addr" -> rs[a] + rs[b]
      "addi" -> rs[a] + b
      "seti" -> a
      "setr" -> rs[a]
      "mulr" -> rs[a] * rs[b]
      "muli" -> rs[a] * b
      "eqrr" -> if rs[a] == rs[b], do: 1, else: 0
      "eqri" -> if rs[a] == b, do: 1, else: 0
      "gtrr" -> if rs[a] > rs[b], do: 1, else: 0
      "gtir" -> if a > rs[b], do: 1, else: 0
      "bani" -> Bitwise.band(rs[a], b)
      "bori" -> Bitwise.bor(rs[a], b)
      n -> raise "unknown op #{n}"
    end
    |> then(&Map.put(rs, c, &1))
  end

  def input() do
    [ip | ins] =
      File.stream!("./input.txt")
      |> Stream.map(&String.trim/1)
      |> Enum.to_list()

    {parse_ip(ip), parse_ins(ins)}
  end

  def parse_ip(ip) do
    ip
    |> String.split(" ")
    |> Enum.at(1)
    |> String.to_integer()
    |> then(fn i -> {i, 0} end)
  end

  def parse_ins(ins) do
    ins
    |> Enum.with_index()
    |> Map.new(fn {s, i} ->
      [op | rs] = String.split(s, " ")
      [a, b, c] = rs |> Enum.map(&String.to_integer/1)
      {i, {op, a, b, c}}
    end)
  end
end
