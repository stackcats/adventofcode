defmodule Solution do
  @pos {12, 12}

  def part1() do
    input()
    |> run(10000, &flip/2)
  end

  def part2() do
    input()
    |> run(10_000_000, &evolve_flip/2)
  end

  def run(map, rounds, infect_fn) do
    for _ <- 1..rounds, reduce: {map, @pos, :up, 0} do
      {map, pos, dir, ct} ->
        dir =
          case Map.get(map, pos, ".") do
            "." -> turn_left(dir)
            "#" -> turn_right(dir)
            "w" -> dir
            "f" -> turn_back(dir)
          end

        map = infect_fn.(map, pos)
        ct = if map[pos] == "#", do: ct + 1, else: ct
        pos = go_head(pos, dir)
        {map, pos, dir, ct}
    end
    |> elem(3)
  end

  def turn_left(:up), do: :left
  def turn_left(:left), do: :down
  def turn_left(:down), do: :right
  def turn_left(:right), do: :up

  def turn_right(:up), do: :right
  def turn_right(:right), do: :down
  def turn_right(:down), do: :left
  def turn_right(:left), do: :up

  def turn_back(:up), do: :down
  def turn_back(:left), do: :right
  def turn_back(:down), do: :up
  def turn_back(:right), do: :left

  def flip(map, pos) do
    node = if Map.get(map, pos, ".") == ".", do: "#", else: "."
    Map.put(map, pos, node)
  end

  def evolve_flip(map, pos) do
    node =
      case Map.get(map, pos, ".") do
        "." -> "w"
        "w" -> "#"
        "#" -> "f"
        "f" -> "."
      end

    Map.put(map, pos, node)
  end

  def go_head({x, y}, dir) do
    case dir do
      :up -> {x - 1, y}
      :down -> {x + 1, y}
      :left -> {x, y - 1}
      :right -> {x, y + 1}
    end
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.graphemes/1)
    |> Enum.to_list()
    |> to_map()
  end

  def to_map(lst) do
    lst
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {row, i}, acc ->
      row
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {c, j}, acc ->
        Map.put(acc, {i, j}, c)
      end)
    end)
  end
end
