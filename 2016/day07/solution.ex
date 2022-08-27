defmodule Solution do
  def part1() do
    abbas = all_abba()

    input()
    |> Enum.count(&support_tls?(&1, abbas))
  end

  def part2() do
    aba_bab = all_aba_bab()

    input()
    |> Enum.count(&support_ssl?(&1, aba_bab))
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.split(&1, ["[", "]"]))
    |> Stream.map(&group/1)
    |> Enum.to_list()
  end

  def all_abba() do
    for a <- ?a..?z, b <- ?a..?z, a != b do
      List.to_string([a, b, b, a])
    end
  end

  def all_aba_bab do
    for a <- ?a..?z, b <- ?a..?z, a != b do
      {List.to_string([a, b, a]), List.to_string([b, a, b])}
    end
  end

  def group(lst), do: group(lst, false, [], [])

  def group([], _, outs, ins), do: {outs, ins}

  def group([x | xs], square?, outs, ins) do
    if square? do
      group(xs, not square?, outs, [x | ins])
    else
      group(xs, not square?, [x | outs], ins)
    end
  end

  def support_tls?({outs, ins}, abbas) do
    abbas |> Enum.any?(fn abba -> Enum.any?(outs, &String.contains?(&1, abba)) end) &&
      not (abbas |> Enum.any?(fn abba -> Enum.any?(ins, &String.contains?(&1, abba)) end))
  end

  def support_ssl?({outs, ins}, aba_bab) do
    aba_bab
    |> Enum.any?(fn {aba, bab} ->
      Enum.any?(outs, &String.contains?(&1, aba)) && Enum.any?(ins, &String.contains?(&1, bab))
    end)
  end
end
