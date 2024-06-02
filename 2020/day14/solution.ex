defmodule Solution do
  def part1() do
    trans = fn
      {"0", _} -> 0
      {"1", _} -> 1
      {_, n} -> n
    end

    run(fn
      {:mask, mask}, {_, mem} ->
        {mask, mem}

      [addr, value], {mask, mem} ->
        apply_mask(mask, value, trans, fn v -> [v] end)
        |> Enum.reduce(mem, &Map.put(&2, addr, &1))
        |> then(fn m -> {mask, m} end)
    end)
  end

  def part2() do
    trans = fn
      {"0", n} -> n
      {"1", _} -> 1
      _ -> "X"
    end

    run(fn
      {:mask, mask}, {_, mem} ->
        {mask, mem}

      [addr, value], {mask, mem} ->
        apply_mask(mask, addr, trans, &apply_float/1)
        |> Enum.reduce(mem, &Map.put(&2, &1, value))
        |> then(fn m -> {mask, m} end)
    end)
  end

  def run(f) do
    input()
    |> Enum.reduce({"", %{}}, f)
    |> elem(1)
    |> Map.values()
    |> Enum.sum()
  end

  def apply_mask(mask, value, trans, reduce) do
    value = Integer.digits(value, 2)

    Enum.zip(mask, lpad(value, 36))
    |> Enum.map(trans)
    |> reduce.()
    |> Enum.map(&Integer.undigits(&1, 2))
  end

  def apply_float([]), do: [[]]

  def apply_float([x | xs]) do
    case x do
      0 -> cons(0, xs)
      1 -> cons(1, xs)
      _ -> cons(0, xs) ++ cons(1, xs)
    end
  end

  def cons(n, lst) do
    lst |> apply_float() |> Enum.map(&[n | &1])
  end

  def lpad(lst, size) do
    diff = size - length(lst)

    if diff <= 0 do
      lst
    else
      Enum.map(1..diff, fn _ -> 0 end) ++ lst
    end
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(fn
      "mask = " <> mask ->
        {:mask, String.graphemes(mask)}

      s ->
        Regex.run(~r/mem\[(\d+)\] = (\d+)/, s)
        |> Enum.drop(1)
        |> Enum.map(&String.to_integer/1)
    end)
  end
end
