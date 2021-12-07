defmodule Solution do
  def part1() do
    lst = input()
    m = median(lst)
    Enum.reduce(lst, 0, fn n, acc -> abs(m - n) + acc end)
  end

  def part2() do
    lst = input()
    m = mean(lst)

    (m - 2)..(m + 2)
    |> Enum.map(fn m ->
      Enum.reduce(lst, 0, fn n, acc -> gauss(abs(n - m)) + acc end)
    end)
    |> Enum.min()
  end

  defp median(lst) do
    lst = Enum.sort(lst)
    ct = Enum.count(lst)
    half = Enum.drop(lst, div(ct, 2) - 1)

    if rem(ct, 2) == 1 do
      List.first(half)
    else
      [a, b | _] = half
      div(a + b, 2)
    end
  end

  defp mean(lst) do
    round(Enum.sum(lst) / Enum.count(lst))
  end

  defp input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.split(&1, ","))
    |> Enum.to_list()
    |> List.first()
    |> Enum.map(&String.to_integer/1)
  end

  defp gauss(n) do
    (1 + n) * n / 2
  end
end
