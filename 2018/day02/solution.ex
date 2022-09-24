defmodule Solution do
  def part1() do
    input()
    |> Enum.map(fn xs ->
      xs
      |> Enum.reduce(%{}, fn c, acc ->
        Map.update(acc, c, 1, &(&1 + 1))
      end)
      |> Map.values()
      |> MapSet.new()
      |> then(fn set ->
        {MapSet.member?(set, 2), MapSet.member?(set, 3)}
      end)
    end)
    |> Enum.reduce({0, 0}, fn {a, b}, {acc, bcc} ->
      {acc + ((a && 1) || 0), bcc + ((b && 1) || 0)}
    end)
    |> then(fn {a, b} -> a * b end)
  end

  def part2() do
    ids = input()

    find_correct(ids, ids)
    |> then(fn {a, b} ->
      Enum.zip(a, b)
      |> Enum.flat_map(fn {a, b} ->
        if a == b, do: [a], else: []
      end)
      |> Enum.join()
    end)
  end

  def find_correct([], _), do: nil

  def find_correct([x | xs], ys) do
    y = ys |> Enum.find(fn y -> correct?(y, x) end)

    if y do
      {x, y}
    else
      find_correct(xs, ys)
    end
  end

  def correct?(a, b) do
    Enum.zip(a, b)
    |> Enum.filter(fn {a, b} -> a != b end)
    |> Enum.count()
    |> then(&(&1 == 1))
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.graphemes/1)
    |> Enum.to_list()
  end
end
