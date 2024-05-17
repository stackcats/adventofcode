defmodule Solution do
  defmodule Cave do
    defstruct i: %{}, e: %{}, depth: 0, target: nil

    def new(depth, target) do
      %Cave{depth: depth, target: target}
    end

    def geo_index(cave, {x, y} = pos) do
      case cave.i[pos] do
        nil ->
          {i, cave} =
            cond do
              pos == {0, 0} ->
                {0, cave}

              pos == cave.target ->
                {0, cave}

              x == 0 ->
                {y * 48271, cave}

              y == 0 ->
                {x * 16807, cave}

              true ->
                {e1, cave} = erosion(cave, {x - 1, y})
                {e2, cave} = erosion(cave, {x, y - 1})
                {e1 * e2, cave}
            end

          cave = %{cave | i: Map.put(cave.i, pos, i)}
          {i, cave}

        i ->
          {i, cave}
      end
    end

    def erosion(cave, pos) do
      case cave.e[pos] do
        nil ->
          {i, cave} = geo_index(cave, pos)
          e = rem(i + cave.depth, 20183)
          cave = %{cave | e: Map.put(cave.e, pos, e)}
          {e, cave}

        e ->
          {e, cave}
      end
    end

    def type(cave, pos) do
      {e, cave} = erosion(cave, pos)
      {rem(e, 3), cave}
    end
  end

  def part1() do
    [depth, x, y] = input()

    cave = Cave.new(depth, {x, y})

    for i <- 0..x, j <- 0..y, reduce: {0, cave} do
      {acc, cave} ->
        {t, cave} = Cave.type(cave, {i, j})
        {acc + t, cave}
    end
    |> elem(0)
  end

  # rocky: 0, wet: 1, narrow: 2
  # neither: 0, torch: 1, climbing gear: 2
  @torch 1

  def part2() do
    [depth, x, y] = input()
    cave = Cave.new(depth, {x, y})

    :gb_sets.add({0, {0, 0}, @torch}, :gb_sets.empty())
    |> dijkstra(cave, %{})
  end

  def dijkstra(pq, cave, visited) do
    {{minutes, pos, equipped}, pq} = :gb_sets.take_smallest(pq)

    cond do
      pos == cave.target && equipped == @torch ->
        minutes

      minutes >= Map.get(visited, {pos, equipped}, minutes + 10) ->
        dijkstra(pq, cave, visited)

      true ->
        visited = Map.put(visited, {pos, equipped}, minutes)

        {pq, cave} = move(pq, minutes, pos, equipped, cave)

        # change equipped
        {curr_type, cave} = Cave.type(cave, pos)
        new_equipped = 3 - equipped - curr_type
        pq = :gb_sets.add({minutes + 7, pos, equipped}, pq)

        dijkstra(pq, cave, visited)
    end
  end

  def move(pq, minutes, {x, y}, equipped, cave) do
    [{-1, 0}, {0, 1}, {1, 0}, {0, -1}]
    |> Enum.reduce({pq, cave}, fn {dx, dy}, {pq, cave} ->
      pos = {x, y} = {x + dx, y + dy}

      if x < 0 or y < 0 do
        {pq, cave}
      else
        {curr_type, cave} = Cave.type(cave, pos)

        if equipped == curr_type do
          {pq, cave}
        else
          {:gb_sets.add({minutes + 1, pos, equipped}, pq), cave}
        end
      end
    end)
  end

  def input() do
    Regex.scan(~r/\d+/, File.read!("./input.txt"))
    |> Enum.map(fn [n] -> String.to_integer(n) end)
  end
end
