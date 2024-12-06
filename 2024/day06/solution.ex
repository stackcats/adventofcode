defmodule Solution do
  def part1() do
    g = input()

    {start, _} = Enum.find(g, fn {_, c} -> c == "^" end)

    {_, path} = move(g, start, {-1, 0}, %MapSet{}, %MapSet{})

    MapSet.size(path)
  end

  def part2() do
    g = input()

    {start, _} = Enum.find(g, fn {_, c} -> c == "^" end)

    {_, path} = move(g, start, {-1, 0}, %MapSet{}, %MapSet{})

    path
    |> Enum.count(fn p ->
      g
      |> Map.put(p, "#")
      |> move(start, {-1, 0}, %MapSet{}, %MapSet{})
      |> case do
        :error -> true
        _ -> false
      end
    end)
  end

  def move(g, pos, dir, path, seen) do
    cond do
      {pos, dir} in seen ->
        :error

      g[pos] == nil ->
        {:ok, path}

      true ->
        next = forward(pos, dir)
        seen = MapSet.put(seen, {pos, dir})

        if g[next] == "#" do
          dir = turn_right(dir)
          move(g, pos, dir, path, seen)
        else
          move(g, next, dir, MapSet.put(path, pos), seen)
        end
    end
  end

  def forward({x, y}, {dx, dy}) do
    {x + dx, y + dy}
  end

  def turn_right({dx, dy}) do
    {dy, -dx}
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {s, i}, acc ->
      s
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {c, j}, acc ->
        Map.put(acc, {i, j}, c)
      end)
    end)
  end
end
