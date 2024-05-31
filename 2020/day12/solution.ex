defmodule Solution do
  def part1() do
    input()
    |> Enum.reduce({0, 0, 1}, fn
      {"N", n}, {x, y, dir} ->
        {x - n, y, dir}

      {"S", n}, {x, y, dir} ->
        {x + n, y, dir}

      {"W", n}, {x, y, dir} ->
        {x, y - n, dir}

      {"E", n}, {x, y, dir} ->
        {x, y + n, dir}

      {"L", d}, {x, y, dir} ->
        {x, y, turn_ship(dir, 360 - d)}

      {"R", d}, {x, y, dir} ->
        {x, y, turn_ship(dir, d)}

      {"F", n}, {x, y, dir} ->
        case dir do
          0 -> {-1, 0}
          1 -> {0, 1}
          2 -> {1, 0}
          3 -> {0, -1}
        end
        |> then(fn {dx, dy} -> {x + dx * n, y + dy * n, dir} end)
    end)
    |> then(fn {x, y, _} -> abs(x) + abs(y) end)
  end

  def part2() do
    input()
    |> Enum.reduce({0, 0, -1, 10}, fn
      {"N", n}, {x, y, dx, dy} ->
        {x, y, dx - n, dy}

      {"S", n}, {x, y, dx, dy} ->
        {x, y, dx + n, dy}

      {"W", n}, {x, y, dx, dy} ->
        {x, y, dx, dy - n}

      {"E", n}, {x, y, dx, dy} ->
        {x, y, dx, dy + n}

      {"L", d}, {x, y, dx, dy} ->
        {dx, dy} = turn_waypoint(dx, dy, 360 - d)
        {x, y, dx, dy}

      {"R", d}, {x, y, dx, dy} ->
        {dx, dy} = turn_waypoint(dx, dy, d)
        {x, y, dx, dy}

      {"F", n}, {x, y, dx, dy} ->
        {x + n * dx, y + n * dy, dx, dy}
    end)
    |> then(fn {x, y, _, _} -> abs(x) + abs(y) end)
  end

  def turn_ship(dir, d) do
    rem(dir + div(d, 90), 4)
  end

  def turn_waypoint(dx, dy, d) do
    1..div(d, 90)
    |> Enum.reduce({dx, dy}, fn _, {dx, dy} ->
      {dy, -dx}
    end)
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(fn s ->
      [_, ins, n] = Regex.run(~r/(\w)(\d+)/, s)
      {ins, String.to_integer(n)}
    end)
    |> Enum.to_list()
  end
end
