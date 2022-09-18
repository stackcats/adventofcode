defmodule Solution do
  def part1() do
    map = input()
    IO.inspect(map)
    # map
    # |> Map.keys()
    # |> Enum.filter(fn [a, b] -> a == 0 || b == 0 end)
    # |> Enum.map(fn start ->
    #   dfs(map, start, MapSet.new())
    # end)
  end

  def dfs(map, pin, vistied, cur, ans) do
    if MapSet.member?(vistied, pin) do
      [cur | ans]
    else
      vistied = MapSet.put(vistied, pin)

      map[pin]
      |> Enum.map(fn p ->
        dfs(map, p, vistied, cur ++ [p], ans)
      end)
    end
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(fn s ->
      s
      |> String.split("/")
      |> Enum.map(&String.to_integer/1)
    end)
    |> Enum.to_list()
    |> to_map(%{})
  end

  def to_map([_], acc), do: acc

  def to_map([[a1, b1] = x | xs], acc) do
    acc =
      xs
      |> Enum.reduce(acc, fn [a2, b2] = y, acc ->
        if a1 == a2 || b1 == a2 || a1 == b2 || b1 == b2 do
          acc
          |> Map.update(x, [y], &[y | &1])
          |> Map.update(y, [x], &[x | &1])
        else
          acc
        end
      end)

    to_map(xs, acc)
  end
end
