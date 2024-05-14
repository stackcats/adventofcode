defmodule Solution do
  def part1() do
    input()
    |> Enum.map(&max_geode(&1, 24))
    |> Enum.with_index(1)
    |> Enum.map(fn {g, i} -> g * i end)
    |> Enum.sum()
  end

  def part2() do
    input()
    |> Enum.take(3)
    |> Enum.map(&max_geode(&1, 32))
    |> Enum.product()
  end

  def max_geode(bp, max_time) do
    max_requirements =
      bp |> Enum.zip() |> Enum.map(&Tuple.to_list/1) |> Enum.map(&Enum.max/1)

    init = {[0, 0, 0, 0], [1, 0, 0, 0], 0}

    :queue.from_list([init])
    |> bfs(bp, max_time, 0, max_requirements)
  end

  def bfs(q, bp, max_time, max_geodes, max_requirements) do
    case :queue.out(q) do
      {:empty, _} ->
        max_geodes

      {{_, {inventory, bots, elapsed}}, q} ->
        geodes = Enum.at(inventory, 3) + Enum.at(bots, 3) * (max_time - elapsed)

        max_geodes = max(geodes, max_geodes)

        bp
        |> Enum.with_index()
        |> Enum.reduce(q, fn {costs, i}, q ->
          if i < 3 && Enum.at(bots, i) == Enum.at(max_requirements, i) do
            q
          else
            0..3
            |> Enum.map(fn i ->
              cost = Enum.at(costs, i)
              inv = Enum.at(inventory, i)
              bot = Enum.at(bots, i)

              cond do
                cost <= inv -> 0
                bot == 0 -> max_time + 1
                true -> div(cost - inv + bot - 1, bot)
              end
            end)
            |> Enum.max()
            |> then(fn time ->
              elapsed = elapsed + time + 1

              if elapsed >= max_time do
                q
              else
                new_inventory =
                  [inventory, bots, costs]
                  |> Enum.zip_with(fn [inv, bot, cost] ->
                    inv + bot * (time + 1) - cost
                  end)

                new_bots = List.update_at(bots, i, &(&1 + 1))
                remaining_time = max_time - elapsed

                if (remaining_time - 1) * remaining_time / 2 + Enum.at(new_inventory, 3) +
                     remaining_time * Enum.at(new_bots, 3) <
                     max_geodes do
                  q
                else
                  state = {new_inventory, new_bots, elapsed}
                  :queue.snoc(q, state)
                end
              end
            end)
          end
        end)
        |> bfs(bp, max_time, max_geodes, max_requirements)
    end
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(fn s ->
      [_, a, b, c, d, e, f] =
        ~r/\d+/
        |> Regex.scan(s)
        |> Enum.map(fn d ->
          d |> hd() |> String.to_integer()
        end)

      ore = [a, 0, 0, 0]
      clay = [b, 0, 0, 0]
      obisdian = [c, d, 0, 0]
      geode = [e, 0, f, 0]
      [ore, clay, obisdian, geode]
    end)
    |> Enum.to_list()
  end
end
