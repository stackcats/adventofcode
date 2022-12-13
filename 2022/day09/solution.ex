defmodule Solution do
  def part1() do
    run(2)
  end

  def part2() do
    run(10)
  end

  def run(n) do
    knots = {0, 0} |> List.duplicate(n)
    set = MapSet.new([{0, 0}])

    input()
    |> Enum.reduce({knots, set}, &run_cmd/2)
    |> elem(1)
    |> MapSet.size()
  end

  def run_cmd({c, n}, {knots, set}) do
    {dx, dy} =
      case c do
        "R" -> {0, 1}
        "L" -> {0, -1}
        "U" -> {-1, 0}
        "D" -> {1, 0}
      end

    move(knots, dx, dy, n, set)
  end

  def move(knots, _dx, _dy, 0, set), do: {knots, set}

  def move(knots, dx, dy, ct, set) do
    knots
    |> Enum.reduce([], fn
      {x, y}, [] ->
        [{x + dx, y + dy}]

      {x, y}, [p | _] = new_knots ->
        [move_to_next(p, {x, y}) | new_knots]
    end)
    |> then(fn new_knots ->
      set = MapSet.put(set, hd(new_knots))

      new_knots
      |> Enum.reverse()
      |> move(dx, dy, ct - 1, set)
    end)
  end

  def move_to_next({hx, hy}, {tx, ty}) do
    {dx, dy} = {hx - tx, hy - ty}

    if abs(dx) > 1 || abs(dy) > 1 do
      {tx + standardization(dx), ty + standardization(dy)}
    else
      {tx, ty}
    end
  end

  def standardization(x) do
    cond do
      x > 0 -> 1
      x < 0 -> -1
      true -> 0
    end
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(fn s ->
      [c, n] = s |> String.split(" ")
      {c, String.to_integer(n)}
    end)
    |> Enum.to_list()
  end
end
