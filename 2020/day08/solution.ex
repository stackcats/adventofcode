defmodule Solution do
  def part1() do
    input() |> run(0, 0, %MapSet{}) |> elem(1)
  end

  def part2() do
    ins = input()

    ins
    |> Enum.filter(fn {_, {op, _}} -> op in ["nop", "jmp"] end)
    |> Enum.reduce_while(nil, fn {i, {op, n}}, _ ->
      changed = if op == "nop", do: "jmp", else: "nop"

      r =
        ins
        |> Map.put(i, {changed, n})
        |> run(0, 0, %MapSet{})

      case r do
        {:ok, acc} -> {:halt, acc}
        {:error, _} -> {:cont, nil}
      end
    end)
  end

  def run(ins, i, acc, _seen) when i >= map_size(ins), do: {:ok, acc}

  def run(ins, i, acc, seen) do
    {j, new_acc} =
      case ins[i] do
        {"nop", _} -> {i + 1, acc}
        {"acc", n} -> {i + 1, acc + n}
        {"jmp", n} -> {i + n, acc}
      end

    if j in seen do
      {:error, acc}
    else
      run(ins, j, new_acc, MapSet.put(seen, j))
    end
  end

  def input() do
    File.stream!("input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(fn s ->
      [op, n] = String.split(s, " ")
      {op, String.to_integer(n)}
    end)
    |> Stream.with_index()
    |> Map.new(fn {k, v} -> {v, k} end)
  end
end
