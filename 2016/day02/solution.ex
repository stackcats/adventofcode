defmodule Solution do
  def part1() do
    input()
    |> Enum.reduce({"", {1, 1}}, fn cmd, {code, pos} ->
      {x, y} = get_code(cmd, pos)
      {code <> "#{x * 3 + y + 1}", {x, y}}
    end)
    |> elem(0)
  end

  def get_code(cmd, pos) do
    cmd
    |> Enum.reduce(pos, fn c, {x, y} ->
      case c do
        "U" -> {max(0, x - 1), y}
        "L" -> {x, max(0, y - 1)}
        "D" -> {min(2, x + 1), y}
        "R" -> {x, min(2, y + 1)}
      end
    end)
  end

  def part2() do
    pad =
      keypad()
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {row, i}, acc ->
        row
        |> Enum.with_index()
        |> Enum.reduce(acc, fn {c, j}, acc ->
          Map.put(acc, {i, j}, c)
        end)
      end)

    input()
    |> Enum.reduce({"", {2, 0}}, fn cmd, {code, pos} ->
      pos = get_code2(cmd, pos, pad)
      {code <> pad[pos], pos}
    end)
    |> elem(0)
  end

  def get_code2(cmd, pos, pad) do
    cmd
    |> Enum.reduce(pos, fn c, {x, y} ->
      next_pos =
        case c do
          "U" -> {x - 1, y}
          "L" -> {x, y - 1}
          "D" -> {x + 1, y}
          "R" -> {x, y + 1}
        end

      if Map.get(pad, next_pos, " ") == " " do
        {x, y}
      else
        next_pos
      end
    end)
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.graphemes/1)
    |> Enum.to_list()
  end

  def keypad() do
    File.stream!("./keypad.txt")
    |> Stream.map(&String.trim(&1, "\n"))
    |> Stream.map(&String.graphemes/1)
    |> Enum.to_list()
  end
end
