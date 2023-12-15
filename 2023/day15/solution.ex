defmodule Solution do
  def part1() do
    input()
    |> Stream.map(&hash/1)
    |> Enum.sum()
  end

  def part2() do
    box = 0..255 |> Enum.map(fn i -> {i, []} end) |> Map.new()

    input()
    |> Enum.reduce(box, fn s, acc ->
      if String.ends_with?(s, "-") do
        [label | _] = String.split(s, "-")
        h = hash(label)

        case Enum.find_index(acc[h], fn {l, _} -> l == label end) do
          nil -> acc
          ndx -> Map.update!(acc, h, fn lst -> List.delete_at(lst, ndx) end)
        end
      else
        [label, focal] = String.split(s, "=")
        n = String.to_integer(focal)
        h = hash(label)

        case Enum.find_index(acc[h], fn {l, _} -> l == label end) do
          nil -> Map.update!(acc, h, fn lst -> lst ++ [{label, n}] end)
          ndx -> Map.update!(acc, h, fn lst -> List.replace_at(lst, ndx, {label, n}) end)
        end
      end
    end)
    |> Enum.map(fn {k, lst} ->
      lst
      |> Enum.with_index(1)
      |> Enum.map(fn {{_, n}, i} ->
        (k + 1) * n * i
      end)
      |> Enum.sum()
    end)
    |> Enum.sum()
  end

  def hash(s) do
    s
    |> String.graphemes()
    |> Enum.reduce(0, fn c, acc ->
      rem((acc + :binary.first(c)) * 17, 256)
    end)
  end

  def input() do
    File.read!("./input.txt")
    |> String.trim()
    |> String.split(",")
  end
end
