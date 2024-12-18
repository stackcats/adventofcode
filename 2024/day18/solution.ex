defmodule Solution do
  @row 70
  @col 70
  @exit [@row, @col]

  @ct 1024

  def part1() do
    input() |> Enum.take(@ct) |> shortest_path()
  end

  def part2() do
    g = input() |> Enum.to_list()
    n = find_cut(g, @ct + 1, length(g))

    Enum.at(g, n - 1)
    |> Enum.map(&Integer.to_string/1)
    |> Enum.join(",")
  end

  def find_cut(_g, l, r) when l >= r, do: l

  def find_cut(g, l, r) do
    m = div(l + r, 2)

    g
    |> Enum.take(m)
    |> shortest_path()
    |> case do
      :error -> find_cut(g, l, m)
      _ -> find_cut(g, m + 1, r)
    end
  end

  def shortest_path(g) do
    :queue.from_list([{[0, 0], 0}])
    |> bfs(MapSet.new(g), %MapSet{})
  end

  def bfs(q, g, seen) do
    case :queue.out(q) do
      {:empty, _} ->
        :error

      {{:value, {[x, y] = curr, ct}}, q} ->
        cond do
          curr in seen ->
            bfs(q, g, seen)

          curr == @exit ->
            ct

          curr in g ->
            bfs(q, g, seen)

          x not in 0..@row or y not in 0..@col ->
            bfs(q, g, seen)

          true ->
            seen = MapSet.put(seen, curr)
            ct = ct + 1

            [{-1, 0}, {0, 1}, {1, 0}, {0, -1}]
            |> Enum.reduce(q, fn {dx, dy}, q ->
              :queue.in({[x + dx, y + dy], ct}, q)
            end)
            |> bfs(g, seen)
        end
    end
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(fn s ->
      s
      |> String.trim()
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)
    end)
  end
end
