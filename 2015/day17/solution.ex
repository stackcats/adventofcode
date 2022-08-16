defmodule Solution do
  @liters 150

  def part1() do
    # 0-1 knapsack problem
    input()
    |> Enum.reduce(%{0 => 1}, fn container, acc ->
      for i <- @liters..container//-1, reduce: acc do
        acc -> Map.update(acc, i, acc[i - container] || 0, &(&1 + (acc[i - container] || 0)))
      end
    end)
    |> Map.get(@liters)
  end

  def part2() do
    containers = input() |> Enum.sort()

    minimum =
      for i <- 1..@liters, reduce: %{0 => 0} do
        dp ->
          containers
          |> Enum.reduce_while(dp, fn c, dp ->
            cond do
              c > i ->
                {:halt, dp}

              dp[i - c] != nil ->
                {:cont, Map.update(dp, i, dp[i - c] + 1, &min(&1, dp[i - c] + 1))}

              true ->
                {:cont, dp}
            end
          end)
      end
      |> Map.get(@liters)

    combo(containers, minimum) |> Enum.count(&(Enum.sum(&1) == @liters))
  end

  def combo(_, 0), do: [[]]
  def combo([], _), do: []

  def combo([h | t], n) do
    for(l <- combo(t, n - 1), do: [h | l]) ++ combo(t, n)
  end

  def input do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.to_integer/1)
    |> Enum.to_list()
  end
end
