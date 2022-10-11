defmodule Solution do
  use Bitwise

  def part1() do
    samples()
    |> Enum.count(fn [bef, [_ | args], aft] ->
      ops() |> Enum.count(fn op -> op.(args, bef) == aft end) >= 3
    end)
  end

  def part2() do
    op_num = ops() |> MapSet.size()

    for code <- 0..(op_num - 1), reduce: %{} do
      acc -> Map.put(acc, code, ops())
    end
    |> find_ops(op_num, %{})
    |> then(fn op_map ->
      programs() |> Enum.reduce(%{}, fn [code | args], rs -> op_map[code].(args, rs) end)
    end)
    |> Map.get(0)
  end

  def find_ops(_op_codes, op_num, op_map) when map_size(op_map) == op_num, do: op_map

  def find_ops(op_codes, op_num, op_map) do
    op_codes =
      op_codes
      |> Enum.reduce(%{}, fn {code, os}, acc ->
        known_ops = op_map |> Map.values() |> MapSet.new()
        Map.put(acc, code, os |> MapSet.difference(known_ops))
      end)

    samples()
    |> Enum.reduce(op_codes, fn [bef, [code | args], aft], acc ->
      acc[code]
      |> Enum.filter(fn f -> f.(args, bef) == aft end)
      |> MapSet.new()
      |> then(&Map.put(acc, code, &1))
    end)
    |> then(fn op_codes ->
      op_codes
      |> Enum.filter(fn {_, v} -> MapSet.size(v) == 1 end)
      |> Enum.map(fn {k, v} -> {k, v |> MapSet.to_list() |> hd()} end)
      |> Map.new()
      |> Map.merge(op_map)
      |> then(fn op_map -> find_ops(op_codes, op_num, op_map) end)
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
    |> MapSet.new()
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

  def samples() do
    File.stream!("./samples.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.filter(fn s -> s != "" end)
    |> Stream.chunk_every(3)
    |> Stream.map(fn chunk ->
      chunk
      |> Enum.map(fn s ->
        Regex.scan(~r/\d+/, s) |> Enum.flat_map(& &1) |> Enum.map(&String.to_integer/1)
      end)
      |> then(fn [bef, ins, aft] -> [to_map(bef), ins, to_map(aft)] end)
    end)
    |> Enum.to_list()
  end

  def programs() do
    File.stream!("./programs.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.split/1)
    |> Stream.map(fn lst -> Enum.map(lst, &String.to_integer/1) end)
    |> Enum.to_list()
  end

  def to_map(lst) do
    lst
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {x, i}, acc -> Map.put(acc, i, x) end)
  end
end
