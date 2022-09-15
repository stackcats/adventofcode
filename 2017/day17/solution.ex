defmodule Solution do
  @step 345

  def part1() do
    for i <- 1..2017, reduce: [0] do
      lst ->
        pos = rem(@step, i)
        {front, rear} = Enum.split(lst, pos + 1)
        [i | rear] ++ front
    end
    |> Enum.at(1)
  end

  def part2() do
    for i <- 1..50_000_000, reduce: {0, 1} do
      {pos, n} ->
        pos = rem(pos + @step, i) + 1
        n = if pos == 1, do: i, else: n
        {pos, n}
    end
    |> elem(1)
  end
end
