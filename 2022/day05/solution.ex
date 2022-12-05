defmodule Solution do
  def part1() do
    input() |> run()
  end

  def part2() do
    input() |> run(true)
  end

  def run(lst, rev? \\ false) do
    stacks = read_stacks()

    lst
    |> Enum.reduce(stacks, fn [n, from, to], acc ->
      move(acc, n, from, to, rev?)
    end)
    |> Enum.map(fn {k, v} -> {k, hd(v)} end)
    |> Enum.sort()
    |> Enum.map(fn {_k, v} -> v end)
    |> Enum.join()
  end

  def move(stacks, 0, _from, _to, _rev?) do
    stacks
  end

  def move(stacks, n, from, to, rev?) do
    pos = if rev?, do: n - 1, else: 0

    {h, r} = stacks[from] |> List.pop_at(pos)

    stacks
    |> Map.put(from, r)
    |> Map.update!(to, &[h | &1])
    |> move(n - 1, from, to, rev?)
  end

  def read_stacks() do
    File.stream!("./stacks.txt")
    |> Enum.reduce(%{}, fn s, acc ->
      lst = s |> String.graphemes()

      for i <- 1..35//4, reduce: {1, acc} do
        {n, acc} ->
          item = Enum.at(lst, i)

          if item == " " do
            {n + 1, acc}
          else
            {n + 1, Map.update(acc, n, [item], &(&1 ++ [item]))}
          end
      end
      |> elem(1)
    end)
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(fn s ->
      Regex.scan(~r/\d+/, s) |> Enum.flat_map(& &1) |> Enum.map(&String.to_integer/1)
    end)
  end
end
