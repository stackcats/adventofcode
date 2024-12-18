defmodule Solution do
  @row 70
  @col 70
  @exit [@row, @col]

  @ct 1024

  def part1() do
    input() |> Enum.take(@ct) |> shortest_path() |> MapSet.size()
  end

  def part2() do
    {lft, rht} = input() |> Enum.split(@ct)

    rht
    |> Enum.reduce_while(MapSet.new(lft), fn pos, acc ->
      acc = MapSet.put(acc, pos)

      if shortest_path(acc) == :error do
        {:halt, pos}
      else
        {:cont, acc}
      end
    end)
    |> Enum.map(&Integer.to_string/1)
    |> Enum.join(",")
  end

  def shortest_path(g) do
    :queue.from_list([{[0, 0], %MapSet{}}])
    |> bfs(g, %MapSet{})
  end

  def bfs(q, g, seen) do
    case :queue.out(q) do
      {:empty, _} ->
        :error

      {{:value, {[x, y] = curr, path}}, q} ->
        cond do
          curr in seen ->
            bfs(q, g, seen)

          curr == @exit ->
            path

          curr in g ->
            bfs(q, g, seen)

          x not in 0..@row or y not in 0..@col ->
            bfs(q, g, seen)

          true ->
            seen = MapSet.put(seen, curr)
            path = MapSet.put(path, curr)

            [{-1, 0}, {0, 1}, {1, 0}, {0, -1}]
            |> Enum.reduce(q, fn {dx, dy}, q ->
              :queue.in({[x + dx, y + dy], path}, q)
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
