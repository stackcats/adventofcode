defmodule Solution do
  @width 101
  @height 103

  def part1() do
    run(fn _, ct -> ct == 100 end)
    |> elem(0)
    |> count()
    |> Enum.product()
  end

  def part2() do
    {robots, ct} = run(fn robots, _ -> not has_overlap?(robots) end)
    print(robots)
    ct
  end

  def has_overlap?(robots) do
    MapSet.new(robots, fn {_, pos} -> pos end) |> MapSet.size() != map_size(robots)
  end

  def print(robots) do
    robots =
      Enum.reduce(robots, %{}, fn {_, p}, acc ->
        Map.update(acc, p, 1, &(1 + &1))
      end)

    for y <- 0..(@height - 1) do
      for x <- 0..(@width - 1) do
        "#{Map.get(robots, [x, y], ".")}"
      end
      |> Enum.join("")
    end
    |> Enum.join("\n")
    |> IO.puts()
  end

  def count(robots) do
    robots
    |> Enum.reduce([0, 0, 0, 0], fn {_, [x, y]}, [q1, q2, q3, q4] ->
      w = div(@width, 2)
      h = div(@height, 2)

      case {cmp(x, w), cmp(y, h)} do
        {:lt, :lt} -> [q1 + 1, q2, q3, q4]
        {:gt, :lt} -> [q1, q2 + 1, q3, q4]
        {:lt, :gt} -> [q1, q2, q3 + 1, q4]
        {:gt, :gt} -> [q1, q2, q3, q4 + 1]
        _ -> [q1, q2, q3, q4]
      end
    end)
  end

  def cmp(a, a), do: :eq
  def cmp(a, b) when a < b, do: :lt
  def cmp(_, _), do: :gt

  def run(f) do
    {robots, velocity} = input()
    loop(robots, velocity, 0, f)
  end

  def loop(robots, velocity, ct, finish?) do
    if finish?.(robots, ct) do
      {robots, ct}
    else
      robots
      |> Map.new(fn {i, pos} ->
        {i, move(pos, velocity[i])}
      end)
      |> loop(velocity, ct + 1, finish?)
    end
  end

  def move([x, y], [dx, dy]) do
    [rem(x + dx + @width, @width), rem(y + dy + @height, @height)]
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(fn s ->
      Regex.scan(~r/-?\d+/, s)
      |> List.flatten()
      |> Enum.map(&String.to_integer/1)
      |> Enum.chunk_every(2)
    end)
    |> Enum.with_index()
    |> Enum.reduce({%{}, %{}}, fn {[p, v], i}, {robots, velocity} ->
      {Map.put(robots, i, p), Map.put(velocity, i, v)}
    end)
  end
end
