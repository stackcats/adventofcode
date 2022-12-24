defmodule Solution do
  def part1() do
    input()
    |> run(10, ["N", "S", "W", "E"])
    |> then(&(area(&1) - MapSet.size(&1)))
  end

  def part2() do
    input()
    |> run2(1, ["N", "S", "W", "E"])
  end

  def run(elves, 0, _directions), do: elves

  def run(elves, rounds, directions) do
    {elves, directions} = one_round(elves, directions)
    run(elves, rounds - 1, directions)
  end

  def run2(elves, ct, directions) do
    case one_round(elves, directions) do
      :stop -> ct
      {elves, directions} -> run2(elves, ct + 1, directions)
    end
  end

  def one_round(elves, directions) do
    elves
    |> Enum.reduce(%{}, fn elf, acc ->
      if not has_neighbor?(elf, elves) do
        acc
      else
        new_pos = try_move(elf, elves, directions)

        if new_pos == nil do
          acc
        else
          Map.update(acc, new_pos, [elf], &[elf | &1])
        end
      end
    end)
    |> then(fn new_positions ->
      if map_size(new_positions) == 0 do
        :stop
      else
        new_positions
        |> Enum.filter(fn {_, v} -> length(v) == 1 end)
        |> Enum.reduce(elves, fn {new_pos, [elf]}, acc ->
          acc
          |> MapSet.delete(elf)
          |> MapSet.put(new_pos)
        end)
        |> then(fn new_elves ->
          {new_elves, shift(directions)}
        end)
      end
    end)
  end

  def area(elves) do
    up = elves |> Enum.min_by(fn {x, _} -> x end) |> elem(0)
    bottom = elves |> Enum.max_by(fn {x, _} -> x end) |> elem(0)
    left = elves |> Enum.min_by(fn {_, y} -> y end) |> elem(1)
    right = elves |> Enum.max_by(fn {_, y} -> y end) |> elem(1)
    (bottom - up + 1) * (right - left + 1)
  end

  def shift([x | xs]), do: xs ++ [x]

  def try_move({x, y}, elves, directions) do
    directions
    |> Enum.find(fn dir ->
      case dir do
        "N" -> [{-1, -1}, {-1, 0}, {-1, 1}]
        "S" -> [{1, -1}, {1, 0}, {1, 1}]
        "W" -> [{-1, -1}, {0, -1}, {1, -1}]
        "E" -> [{-1, 1}, {0, 1}, {1, 1}]
      end
      |> Enum.all?(fn {dx, dy} ->
        {x + dx, y + dy} not in elves
      end)
    end)
    |> then(fn dir ->
      case dir do
        nil -> nil
        "N" -> {x - 1, y}
        "S" -> {x + 1, y}
        "W" -> {x, y - 1}
        "E" -> {x, y + 1}
      end
    end)
  end

  def has_neighbor?({x, y}, elves) do
    [{-1, -1}, {-1, 0}, {-1, 1}, {0, -1}, {0, 1}, {1, -1}, {1, 0}, {1, 1}]
    |> Enum.any?(fn {dx, dy} ->
      {x + dx, y + dy} in elves
    end)
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.graphemes/1)
    |> to_map
  end

  def to_map(lst) do
    lst
    |> Enum.with_index()
    |> Enum.reduce(%MapSet{}, fn {row, i}, acc ->
      row
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {c, j}, acc ->
        if c == "#" do
          MapSet.put(acc, {i, j})
        else
          acc
        end
      end)
    end)
  end
end
