defmodule Solution do
  def part1() do
    {locks, keys} = input()

    for l <- locks, k <- keys, reduce: 0 do
      acc ->
        Enum.zip(l, k)
        |> Enum.any?(fn {l, k} -> l + k > 5 end)
        |> if do
          acc
        else
          acc + 1
        end
    end
  end

  def input() do
    File.read!("./input.txt")
    |> String.split("\n\n", trim: true)
    |> Enum.reduce({[], []}, fn s, {locks, keys} ->
      if String.starts_with?(s, "#") do
        {[heights(s) | locks], keys}
      else
        {locks, [heights(s) | keys]}
      end
    end)
  end

  def heights(s) do
    s
    |> String.split("\n", trim: true)
    |> Enum.map(&String.graphemes/1)
    |> Enum.zip()
    |> Stream.map(&Tuple.to_list/1)
    |> Stream.map(fn row -> Enum.count(row, &(&1 == "#")) - 1 end)
    |> Enum.to_list()
  end
end
