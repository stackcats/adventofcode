defmodule Solution do
  @duration 2503

  def part1() do
    input()
    |> Enum.map(fn [a, b, c] ->
      div(@duration, b + c) * a * b + min(rem(@duration, b + c), b) * a
    end)
    |> Enum.max()
  end

  def part2() do
    reindeers =
      input()
      |> Enum.map(fn e -> [0, 0 | e] end)

    for i <- 0..@duration, reduce: reindeers do
      acc ->
        acc =
          acc
          |> Enum.map(fn [distance, points, speed, run_duration, rest_duration] = reindeer ->
            if rem(i, run_duration + rest_duration) < run_duration do
              [distance + speed, points, speed, run_duration, rest_duration]
            else
              reindeer
            end
          end)

        fastest = acc |> Enum.max_by(&hd/1) |> hd()

        acc
        |> Enum.map(fn [distance, points | rest] = reindeer ->
          if distance == fastest do
            [distance, points + 1 | rest]
          else
            reindeer
          end
        end)
    end
    |> Enum.max_by(fn [_, points | _] -> points end)
    |> Enum.at(1)
  end

  def input() do
    reg = ~r/(\d)+/

    File.stream!("./input.txt")
    |> Stream.map(fn s ->
      Regex.scan(reg, s)
      |> Enum.map(fn e -> hd(e) end)
      |> Enum.map(&String.to_integer/1)
    end)
    |> Enum.to_list()
  end
end
