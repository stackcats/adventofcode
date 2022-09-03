defmodule Solution do
  defmodule Node do
    defstruct [:size, :used, :avail, :percent]

    def from_map(m) do
      opts = m |> Map.to_list() |> Enum.map(fn {k, v} -> {String.to_existing_atom(k), v} end)
      struct(__MODULE__, opts)
    end
  end

  def part1() do
    grid = input()

    for {k1, v1} <- grid, {k2, v2} <- grid, k1 != k2, reduce: 0 do
      acc -> acc + if v1.used > 0 && v1.used <= v2.avail, do: 1, else: 0
    end
  end

  def part2() do
    grid = input()
    {x, _} = grid |> Map.keys() |> Enum.max()
    top_right = {x, 0}
    target = {x - 1, 0}

    grid
    |> Enum.filter(fn {_, v} -> v.avail >= grid[top_right].used end)
    |> Enum.map(fn {k, _} ->
      :queue.new()
      |> :queue.snoc({k, 0})
      |> bfs(target, grid, MapSet.new(), grid[k].avail)
    end)
    |> Enum.min()
    |> then(&(&1 + 33 * 5 + 1))
  end

  def bfs(q, target, grid, visited, capacity) do
    {pos, steps} = :queue.head(q)
    q = :queue.tail(q)

    cond do
      pos == target ->
        steps

      MapSet.member?(visited, pos) ->
        bfs(q, target, grid, visited, capacity)

      true ->
        neighbors(pos, grid, capacity)
        |> Enum.reduce(q, fn new_pos, q ->
          :queue.in({new_pos, steps + 1}, q)
        end)
        |> bfs(target, grid, MapSet.put(visited, pos), capacity)
    end
  end

  def neighbors({x, y}, grid, capacity) do
    [{-1, 0}, {0, 1}, {1, 0}, {0, -1}]
    |> Enum.filter(fn {dx, dy} ->
      nx = dx + x
      ny = dy + y
      grid[{nx, ny}] != nil && grid[{nx, ny}].used <= capacity
    end)
    |> Enum.map(fn {dx, dy} -> {x + dx, y + dy} end)
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.drop(2)
    |> Stream.map(&String.trim/1)
    |> Stream.map(fn s ->
      ~r/.*-x(?<x>\d+)-y(?<y>\d+)\s*(?<size>\d+)T\s*(?<used>\d+)T\s*(?<avail>\d+)T\s*(?<percent>\d+)%/
      |> Regex.named_captures(s)
      |> Enum.reduce(%{}, fn {k, v}, acc ->
        Map.put(acc, k, String.to_integer(v))
      end)
    end)
    |> Enum.reduce(%{}, fn cap, acc ->
      Map.put(acc, {cap["x"], cap["y"]}, Node.from_map(cap))
    end)
  end
end
