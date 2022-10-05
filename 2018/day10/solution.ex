defmodule Solution do
  def part1 do
    input()
    |> loop()
    |> elem(0)
    |> print()
  end

  def part2 do
    input()
    |> loop()
    |> elem(1)
  end

  def loop(points, t \\ 0) do
    next_tick_points = tick(points)

    if area(next_tick_points) > area(points) do
      {points, t}
    else
      loop(next_tick_points, t + 1)
    end
  end

  def area(points) do
    {u, d, l, r} = border(points)
    (r - l) * (d - u)
  end

  def tick(points) do
    points
    |> Enum.map(fn {px, py, vx, vy} ->
      {px + vx, py + vy, vx, vy}
    end)
  end

  def border([{px, py, _, _} | ps]) do
    ps
    |> Enum.reduce({py, py, px, px}, fn {x, y, _, _}, {up, down, left, right} ->
      {min(up, y), max(down, y), min(left, x), max(right, x)}
    end)
  end

  def print(points) do
    points
    |> border()
    |> then(fn {up, down, left, right} ->
      for i <- up..down do
        for j <- left..right do
          if Enum.find(points, fn {px, py, _, _} ->
               py == i && px == j
             end) do
            IO.write("#")
          else
            IO.write(".")
          end
        end

        IO.puts("")
      end

      IO.puts("")
    end)
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.replace(&1, " ", ""))
    |> Stream.map(fn s ->
      r = ~r/position=<(?<px>[^,]+),(?<py>[^>]+)>velocity=<(?<vx>[^,]+),(?<vy>[^>]+)>/

      Regex.named_captures(r, s)
      |> Enum.map(fn {k, v} -> {k, String.to_integer(v)} end)
      |> Map.new()
      |> then(fn m ->
        {m["px"], m["py"], m["vx"], m["vy"]}
      end)
    end)
    |> Enum.to_list()
  end
end
