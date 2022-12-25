defmodule Solution do
  def part1(), do: aux(&next_pos/3)

  def part2(), do: aux(&next_cube_pos/3)

  def aux(func) do
    {{x, y}, step} = run(input(), {0, 50}, map(), {0, 1}, func)
    1000 * (x + 1) + 4 * (y + 1) + facing_score(step)
  end

  def run([], curr, _m, step, _next_fn), do: {curr, step}

  def run([c | cs], curr, m, step, next_fn) do
    if c in ["L", "R"] do
      run(cs, curr, m, turn(step, c), next_fn)
    else
      {next, step} = move(curr, c, m, step, next_fn)
      run(cs, next, m, step, next_fn)
    end
  end

  def move(curr, 0, _m, step, _next_fn), do: {curr, step}

  def move({x, y}, n, g, {dx, dy}, next_fn) do
    {next, step} = next_fn.({x + dx, y + dy}, g, {dx, dy})

    case g[next] do
      "." -> move(next, n - 1, g, step, next_fn)
      # do not turn 
      "#" -> {{x, y}, {dx, dy}}
    end
  end

  def next_pos({x, y}, g, {dx, dy}) do
    cond do
      x == 200 -> next_pos({0, y}, g, {dx, dy})
      x == -1 -> next_pos({199, y}, g, {dx, dy})
      y == 150 -> next_pos({x, 0}, g, {dx, dy})
      y == -1 -> next_pos({x, 149}, g, {dx, dy})
      g[{x, y}] == nil -> next_pos({x + dx, y + dy}, g, {dx, dy})
      true -> {{x, y}, {dx, dy}}
    end
  end

  def next_cube_pos({x, y}, _g, {dx, dy}) do
    cond do
      # 1
      x < 0 && y >= 50 && y < 100 -> {{y + 100, 0}, {0, 1}}
      x >= 150 && x < 200 && y < 0 -> {{0, x - 100}, {1, 0}}
      # 2
      x < 0 && y >= 100 && y < 150 -> {{199, y - 100}, {-1, 0}}
      x >= 200 && y >= 0 && y < 50 -> {{0, y + 100}, {1, 0}}
      # 3
      x >= 0 && x < 50 && y == 49 -> {{150 - x - 1, 0}, {0, 1}}
      x >= 100 && x < 150 && y < 0 -> {{150 - x - 1, 50}, {0, 1}}
      # 4
      x >= 0 && x < 50 && y >= 150 -> {{150 - x - 1, 99}, {0, -1}}
      x >= 100 && x < 150 && y == 100 -> {{150 - x - 1, 149}, {0, -1}}
      # 5
      x == 50 && y >= 100 && y < 150 -> {{y - 50, 99}, {0, -1}}
      x >= 50 && x < 100 && y == 100 -> {{49, x + 50}, {-1, 0}}
      # 6
      x >= 50 && x < 100 && y == 49 -> {{100, x - 50}, {1, 0}}
      x == 99 && y >= 0 && y < 50 -> {{y + 50, 50}, {0, 1}}
      # 7
      x == 150 && y >= 50 && y < 100 -> {{y + 100, 49}, {0, -1}}
      x >= 150 && x < 200 && y == 50 -> {{149, x - 100}, {-1, 0}}
      true -> {{x, y}, {dx, dy}}
    end
  end

  def facing_score({-1, 0}), do: 3
  def facing_score({0, 1}), do: 0
  def facing_score({1, 0}), do: 1
  def facing_score({0, -1}), do: 2

  def turn({dx, dy}, "L"), do: {-dy, dx}
  def turn({dx, dy}, "R"), do: {dy, -dx}

  def input() do
    File.stream!("./input.txt")
    |> Enum.to_list()
    |> hd()
    |> String.trim()
    |> then(fn s ->
      r = ~r/(\d+|R|L)/

      Regex.scan(r, s)
      |> Enum.map(fn [x, _] ->
        case x do
          "R" -> "R"
          "L" -> "L"
          _ -> String.to_integer(x)
        end
      end)
    end)
  end

  def map() do
    File.stream!("./map.txt")
    |> Stream.map(&String.trim(&1, "\n"))
    |> Stream.map(&String.graphemes/1)
    |> build_map()
  end

  def build_map(lst) do
    lst
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {row, i}, acc ->
      row
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {c, j}, acc ->
        if c != " ", do: Map.put(acc, {i, j}, c), else: acc
      end)
    end)
  end
end
