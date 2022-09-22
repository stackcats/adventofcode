defmodule Solution do
  def part1() do
    run(5)
  end

  def part2() do
    run(18)
  end

  def run(n) do
    s = ".#./..#/###" |> s_to_map()
    rules = input()

    for _ <- 1..n, reduce: s do
      acc ->
        transform(acc, rules)
    end
    |> Map.values()
    |> Enum.count(&(&1 == "#"))
  end

  def transform(grid, rules) do
    size = grid |> map_size() |> :math.sqrt() |> round()
    split_size = if rem(size, 2) == 0, do: 2, else: 3

    range = 0..(size - 1)//split_size

    for i <- range, j <- range, reduce: %{} do
      acc ->
        pattern =
          for x <- 0..(split_size - 1),
              y <- 0..(split_size - 1),
              into: "",
              do: grid[{i + x, j + y}]

        rule = rules[pattern]

        for x <- 0..split_size, y <- 0..split_size, reduce: acc do
          acc ->
            Map.put(
              acc,
              {map_index(i, split_size) + x, map_index(j, split_size) + y},
              rule[{x, y}]
            )
        end
    end
  end

  def map_index(i, size) do
    div(i, size) * (size + 1)
  end

  def rotate(lst) do
    lst
    |> Enum.zip()
    |> Enum.map(fn x -> x |> Tuple.to_list() |> Enum.reverse() end)
  end

  def flip(lst) do
    lst |> Enum.map(&Enum.reverse/1)
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&parse/1)
    |> Enum.reduce(%{}, fn a, b -> Map.merge(a, b) end)
  end

  def parse(s) do
    [pattern, output] =
      s
      |> String.split(" => ")

    pattern = pattern |> s_to_lst()
    output = output |> s_to_map()

    for _ <- 1..5, reduce: {%{}, pattern} do
      {acc, lst} ->
        acc =
          acc
          |> Map.put(lst |> lst_to_s(), output)
          |> Map.put(lst |> flip() |> lst_to_s(), output)

        {acc, rotate(lst)}
    end
    |> elem(0)
  end

  def s_to_lst(s) do
    s
    |> String.split("/")
    |> Enum.map(&String.graphemes/1)
  end

  def lst_to_s(lst) do
    lst
    |> List.flatten()
    |> Enum.join()
  end

  def s_to_map(s) do
    s
    |> String.split("/")
    |> Enum.map(&String.graphemes/1)
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
