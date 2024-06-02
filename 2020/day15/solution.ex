defmodule Solution do
  @nums [0, 14, 1, 3, 7, 9]

  def part1() do
    run(2020)
  end

  def part2() do
    run(30_000_000)
  end

  def run(n) do
    1..n
    |> Enum.reduce({0, %{}, %{}}, fn t, {prev, mp, mp2} ->
      if t <= length(@nums) do
        n = Enum.at(@nums, t - 1)
        {n, Map.put(mp, n, t), mp2}
      else
        n = if mp2[prev] != nil, do: mp[prev] - mp2[prev], else: 0

        {n, Map.put(mp, n, t), Map.put(mp2, n, mp[n])}
      end
    end)
    |> elem(0)
  end
end
