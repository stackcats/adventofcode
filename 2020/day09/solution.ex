defmodule Solution do
  def part1() do
    {lst, rst} = input() |> Enum.split(25)
    check(lst, rst, MapSet.new(lst))
  end

  def part2() do
    lst = input() |> Enum.to_list()
    target = part1()
    find_range(lst, target)
  end

  def find_range([], _), do: nil

  def find_range([x | xs], target) do
    case check_sum(x, xs, [x], target) do
      nil ->
        find_range(xs, target)

      rng ->
        {a, b} = Enum.min_max(rng)
        a + b
    end
  end

  def check_sum(_, [], _, _), do: nil
  def check_sum(acc, _, rng, sum) when acc == sum, do: rng
  def check_sum(acc, _, _, sum) when acc > sum, do: nil

  def check_sum(acc, [x | xs], rng, sum) do
    check_sum(acc + x, xs, [x | rng], sum)
  end

  def check(_lst, [], _st), do: nil

  def check(lst, [x | xs], st) do
    if not Enum.any?(lst, fn n ->
         m = x - n
         m != n and m in st
       end) do
      x
    else
      lst = tl(lst) ++ [x]
      st = st |> MapSet.delete(hd(lst)) |> MapSet.put(x)
      check(lst, xs, st)
    end
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.to_integer/1)
  end
end
