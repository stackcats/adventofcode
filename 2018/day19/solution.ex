defmodule Solution do
  def part1() do
    {ip, ins} = input()
    rs = 0..5 |> Map.new(fn n -> {n, 0} end)
    run(ip, ins, rs) |> Map.get(0)
  end

  def part2() do
    {_, ins} = input()
    {_, _, a, _} = ins[21]
    {_, _, b, _} = ins[23]
    c = 836 + 22 * a + b
    d = c + 10_550_400

    1..d
    |> Enum.reduce(0, fn n, acc ->
      if rem(d, n) == 0, do: acc + n, else: acc
    end)
  end

  def run({_r, i}, ins, rs) when i > map_size(ins) do
    rs
  end

  def run({r, i}, ins, rs) do
    IO.inspect(rs)
    rs = Map.put(rs, r, i) |> doit(ins[i])
    i = rs[r]
    run({r, i + 1}, ins, rs)
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
      "gtrr" -> if rs[a] > rs[b], do: 1, else: 0
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
