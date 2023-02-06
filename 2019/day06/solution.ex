defmodule Solution do
  def part1() do
    {mp, st} = input()

    st
    |> Enum.reduce(0, fn each, acc ->
      {ct, _} = count(mp, each)
      ct + acc
    end)
  end

  def part2() do
    {mp, _} = input()
    {_, ctYou} = count(mp, "YOU")
    {_, ctSan} = count(mp, "SAN")

    ctYou
    |> Enum.filter(fn {k, _} -> ctSan[k] != nil end)
    |> Enum.min_by(fn {k, v} -> v + ctSan[k] end)
    |> then(fn {k, v} -> v + ctSan[k] - 2 end)
  end

  def count(mp, curr, ct \\ 0, ctMp \\ %{}) do
    ctMp = Map.put(ctMp, curr, ct)

    case mp[curr] do
      nil -> {ct, ctMp}
      parent -> count(mp, parent, ct + 1, ctMp)
    end
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.split(&1, ")"))
    |> Enum.reduce({%{}, %MapSet{}}, fn [a, b], {mp, st} ->
      mp = Map.put(mp, b, a)
      st = MapSet.put(st, a) |> MapSet.put(b)
      {mp, st}
    end)
  end
end
