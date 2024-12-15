defmodule Solution do
  def part1() do
    main("O")
  end

  def part2() do
    main("[", true)
  end

  def main(target, extend? \\ false) do
    {g, ms} = input(extend?)
    {start, _} = Enum.find(g, fn {_, c} -> c == "@" end)

    ms
    |> Enum.reduce({g, start}, fn m, {g, curr} -> run(g, curr, m) end)
    |> elem(0)
    |> Enum.filter(fn {_, c} -> c == target end)
    |> Enum.map(fn {{x, y}, _} -> 100 * x + y end)
    |> Enum.sum()
  end

  def run(g, curr, dir) do
    next = next_pos(curr, dir)

    if can_move?(g, next, dir) do
      {g
       |> move(next, dir)
       |> Map.put(next, "@")
       |> Map.put(curr, "."), next}
    else
      {g, curr}
    end
  end

  def can_move?(g, {x, y} = curr, dir) do
    case g[curr] do
      "." -> true
      "#" -> false
      "O" -> can_move?(g, next_pos(curr, dir), dir)
      "[" -> can_move_box_extend?(g, curr, dir)
      "]" -> can_move_box_extend?(g, {x, y - 1}, dir)
    end
  end

  def move(g, {x, y} = curr, dir) do
    case g[curr] do
      "." ->
        g

      "#" ->
        g

      "O" ->
        next = next_pos(curr, dir)

        g
        |> move(next, dir)
        |> Map.put(next, "O")
        |> Map.put(curr, ".")

      "[" ->
        move_box_extend(g, curr, dir)

      "]" ->
        move_box_extend(g, {x, y - 1}, dir)
    end
  end

  def next_pos({x, y}, "^"), do: {x - 1, y}
  def next_pos({x, y}, ">"), do: {x, y + 1}
  def next_pos({x, y}, "v"), do: {x + 1, y}
  def next_pos({x, y}, "<"), do: {x, y - 1}

  def can_move_box_extend?(g, {x, y}, dir) do
    case dir do
      ">" ->
        can_move?(g, {x, y + 2}, dir)

      "<" ->
        can_move?(g, {x, y - 1}, dir)

      _ ->
        {l, r} =
          case dir do
            "^" -> {{x - 1, y}, {x - 1, y + 1}}
            "v" -> {{x + 1, y}, {x + 1, y + 1}}
          end

        case {g[l], g[r]} do
          {".", "."} -> true
          {"[", _} -> can_move?(g, l, dir)
          {"]", _} -> can_move?(g, l, dir) and can_move?(g, r, dir)
          {_, "["} -> can_move?(g, l, dir) and can_move?(g, r, dir)
          _ -> false
        end
    end
  end

  def move_box_extend(g, {x, y} = curr, dir) do
    {l, r} =
      case dir do
        "^" -> {{x - 1, y}, {x - 1, y + 1}}
        ">" -> {{x, y + 1}, {x, y + 2}}
        "v" -> {{x + 1, y}, {x + 1, y + 1}}
        "<" -> {{x, y - 1}, {x, y}}
      end

    case dir do
      ">" -> move(g, r, dir)
      "<" -> move(g, l, dir)
      _ -> move(g, l, dir) |> move(r, dir)
    end
    |> Map.put(curr, ".")
    |> Map.put({x, y + 1}, ".")
    |> Map.put(l, "[")
    |> Map.put(r, "]")
  end

  def input(extend?) do
    [g, moves] = File.read!("./input.txt") |> String.split("\n\n", trim: true)

    g =
      g
      |> String.split("\n", trim: true)
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {s, i}, acc ->
        s = String.graphemes(s)

        if extend? do
          s
          |> Enum.flat_map(fn
            "." -> [".", "."]
            "#" -> ["#", "#"]
            "O" -> ["[", "]"]
            "@" -> ["@", "."]
          end)
        else
          s
        end
        |> Enum.with_index()
        |> Enum.reduce(acc, fn {c, j}, acc -> Map.put(acc, {i, j}, c) end)
      end)

    moves =
      moves
      |> String.split("\n", trim: true)
      |> Enum.join("")
      |> String.graphemes()

    {g, moves}
  end
end
