defmodule Solution do
  use Bitwise

  def part1() do
    input()
    |> Enum.count(fn [bef, ins, aft] ->
      bef = bef |> to_map()
      aft = aft |> to_map()

      ops()
      |> Enum.count(fn op ->
        op.(tl(ins), bef) == aft
      end) >= 3
    end)
  end

  def ops() do
    [
      &addr/2,
      &addi/2,
      &mulr/2,
      &muli/2,
      &banr/2,
      &bani/2,
      &borr/2,
      &bori/2,
      &setr/2,
      &seti/2,
      &gtir/2,
      &gtri/2,
      &gtrr/2,
      &eqir/2,
      &eqri/2,
      &eqrr/2
    ]
  end

  def addr([a, b, c], rs) do
    Map.put(rs, c, Map.get(rs, a, 0) + Map.get(rs, b, 0))
  end

  def addi([a, b, c], rs) do
    Map.put(rs, c, Map.get(rs, a, 0) + b)
  end

  def mulr([a, b, c], rs) do
    Map.put(rs, c, Map.get(rs, a, 0) * Map.get(rs, b, 0))
  end

  def muli([a, b, c], rs) do
    Map.put(rs, c, Map.get(rs, a, 0) * b)
  end

  def banr([a, b, c], rs) do
    Map.put(rs, c, Map.get(rs, a, 0) &&& Map.get(rs, b, 0))
  end

  def bani([a, b, c], rs) do
    Map.put(rs, c, Map.get(rs, a, 0) &&& b)
  end

  def borr([a, b, c], rs) do
    Map.put(rs, c, Map.get(rs, a, 0) ||| Map.get(rs, b, 0))
  end

  def bori([a, b, c], rs) do
    Map.put(rs, c, Map.get(rs, a, 0) ||| b)
  end

  def setr([a, _b, c], rs) do
    Map.put(rs, c, Map.get(rs, a, 0))
  end

  def seti([a, _b, c], rs) do
    Map.put(rs, c, a)
  end

  def gtir([a, b, c], rs) do
    r = (a > Map.get(rs, b, 0)) |> bool_to_int()
    Map.put(rs, c, r)
  end

  def gtri([a, b, c], rs) do
    r = (Map.get(rs, a, 0) > b) |> bool_to_int()
    Map.put(rs, c, r)
  end

  def gtrr([a, b, c], rs) do
    r = (Map.get(rs, a, 0) > Map.get(rs, b, 0)) |> bool_to_int()
    Map.put(rs, c, r)
  end

  def eqir([a, b, c], rs) do
    r = (a == Map.get(rs, b, 0)) |> bool_to_int()
    Map.put(rs, c, r)
  end

  def eqri([a, b, c], rs) do
    r = (Map.get(rs, a, 0) == b) |> bool_to_int()
    Map.put(rs, c, r)
  end

  def eqrr([a, b, c], rs) do
    r = (Map.get(rs, a, 0) == Map.get(rs, b, 0)) |> bool_to_int()
    Map.put(rs, c, r)
  end

  def bool_to_int(true), do: 1
  def bool_to_int(false), do: 0

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.filter(fn s -> s != "" end)
    |> Stream.chunk_every(3)
    |> Stream.map(fn [bef, ins, aft] ->
      [
        bef |> String.replace(~r/[^\d,]/, "") |> String.split(","),
        ins |> String.split(" "),
        aft |> String.replace(~r/[^\d,]/, "") |> String.split(",")
      ]
      |> Enum.map(fn lst -> Enum.map(lst, &String.to_integer/1) end)
    end)
    |> Enum.to_list()
  end

  def to_map(lst) do
    lst
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {x, i}, acc ->
      Map.put(acc, i, x)
    end)
  end
end
