defmodule Solution do
  def part1() do
    lst = input()
    gamma = find1(lst, &>/2, "")
    epsilon = find1(lst, &</2, "")
    gamma * epsilon
  end

  def part2() do
    lst = input()
    oxygen = find2(lst, &>=/2, "")
    co2 = find2(lst, &</2, "")
    oxygen * co2
  end

  defp input() do
    File.stream!("./input.txt")
    |> Stream.map(&(&1 |> String.trim() |> String.graphemes()))
    |> Enum.to_list()
  end

  defp ones_and_zeros(lst) do
    lst
    |> Enum.reduce({0, 0}, fn [x | _], {ones, zeros} ->
      if x == "1" do
        {ones + 1, zeros}
      else
        {ones, zeros + 1}
      end
    end)
  end

  defp find1(lst, f, s) do
    {ones, zeros} = ones_and_zeros(lst)

    target = if f.(ones, zeros), do: "1", else: "0"

    lst = lst |> Enum.map(&Enum.drop(&1, 1))

    if List.first(lst) == [] do
      String.to_integer(s <> target, 2)
    else
      find1(lst, f, s <> target)
    end
  end

  defp find2([x], _f, s), do: (s <> Enum.join(x)) |> String.to_integer(2)

  defp find2(lst, f, s) do
    {ones, zeros} = ones_and_zeros(lst)

    target = if f.(ones, zeros), do: "1", else: "0"

    lst =
      lst
      |> Enum.flat_map(fn [x | rest] ->
        if target == x, do: [rest], else: []
      end)

    find2(lst, f, s <> target)
  end
end
