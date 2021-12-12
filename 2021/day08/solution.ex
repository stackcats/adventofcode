defmodule Solution do
  def part1() do
    input()
    |> Enum.map(fn {_all, digits} ->
      Enum.reduce(digits, 0, fn d, acc ->
        ct = String.length(d)
        acc + if ct == 2 || ct == 4 || ct == 3 || ct == 7, do: 1, else: 0
      end)
    end)
    |> Enum.sum()
  end

  def part2() do
    input()
    |> Enum.map(fn {all, digits} ->
      m = parse(all)

      Enum.reduce(digits, 0, fn d, acc ->
        acc * 10 + m[d]
      end)
    end)
    |> Enum.sum()
  end

  defp parse(digits) do
    one = Enum.find(digits, fn d -> String.length(d) == 2 end)
    three = Enum.find(digits, fn d -> parse3(d, one) end)
    four = Enum.find(digits, fn d -> String.length(d) == 4 end)
    seven = Enum.find(digits, fn d -> String.length(d) == 3 end)
    eight = Enum.find(digits, fn d -> String.length(d) == 7 end)
    six = Enum.find(digits, fn d -> parse6(d, one) end)
    zero = Enum.find(digits, fn d -> parse0(d, four, six) end)
    nine = Enum.find(digits, fn d -> String.length(d) == 6 && d != six && d != zero end)
    five = Enum.find(digits, fn d -> parse5(d, one, nine) end)
    two = Enum.find(digits, fn d -> String.length(d) == 5 && d != five && d != three end)

    %{}
    |> Map.put(zero, 0)
    |> Map.put(one, 1)
    |> Map.put(two, 2)
    |> Map.put(three, 3)
    |> Map.put(four, 4)
    |> Map.put(five, 5)
    |> Map.put(six, 6)
    |> Map.put(seven, 7)
    |> Map.put(eight, 8)
    |> Map.put(nine, 9)
  end

  defp parse0(d, four, six) do
    if d == six || String.length(d) != 6 do
      false
    else
      chars = String.graphemes(d) |> MapSet.new()
      fours = String.graphemes(four) |> MapSet.new()
      r = MapSet.union(chars, fours)
      MapSet.size(r) == 7
    end
  end

  defp parse3(d, one) do
    if String.length(d) != 5 do
      false
    else
      chars = String.graphemes(d) |> MapSet.new()
      ones = String.graphemes(one) |> MapSet.new()
      r = MapSet.union(chars, ones)
      MapSet.size(r) == Enum.count(chars)
    end
  end

  defp parse5(d, one, nine) do
    if String.length(d) != 5 do
      false
    else
      chars = String.graphemes(d) |> MapSet.new()
      ones = String.graphemes(one) |> MapSet.new()
      r = MapSet.union(chars, ones)
      nines = String.graphemes(nine) |> MapSet.new()
      MapSet.equal?(r, nines)
    end
  end

  defp parse6(d, one) do
    if String.length(d) != 6 do
      false
    else
      chars = String.graphemes(d) |> MapSet.new()
      ones = String.graphemes(one) |> MapSet.new()
      r = MapSet.union(chars, ones)
      MapSet.size(r) == 7
    end
  end

  defp input() do
    File.stream!("./input.txt")
    |> Stream.map(fn line -> String.split(line, "|") end)
    |> Stream.map(fn [l, r] ->
      {String.trim(l) |> String.split() |> sort(), String.trim(r) |> String.split() |> sort()}
    end)
    |> Enum.to_list()
  end

  defp sort(lst) do
    Enum.map(lst, fn d ->
      d |> String.graphemes() |> Enum.sort() |> Enum.join()
    end)
  end
end
