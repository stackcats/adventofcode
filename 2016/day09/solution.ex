defmodule Solution do
  def part1() do
    input()
    |> aux(0)
  end

  def part2() do
    input()
    |> aux(0, true)
  end

  def aux(cs, len, recur? \\ false)
  def aux([], len, _), do: len

  def aux([c | cs], len, recur?) do
    if c == "(" do
      {a, b, cs} = parse(cs)
      {sub, rest} = Enum.split(cs, a)
      sub_len = if recur?, do: aux(sub, 0, true), else: a
      aux(rest, len + sub_len * b, recur?)
    else
      aux(cs, len + 1, recur?)
    end
  end

  def parse(cs) do
    parse_left(cs, 0, 0)
  end

  def parse_left(["x" | cs], a, b) do
    parse_right(cs, a, b)
  end

  def parse_left([c | cs], a, b) do
    parse_left(cs, a * 10 + String.to_integer(c), b)
  end

  def parse_right([")" | cs], a, b) do
    {a, b, cs}
  end

  def parse_right([c | cs], a, b) do
    parse_right(cs, a, b * 10 + String.to_integer(c))
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Enum.to_list()
    |> hd()
    |> String.graphemes()
  end
end
