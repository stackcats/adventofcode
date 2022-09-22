defmodule Solution do
  def part1() do
    s = [".#.", "..#", "###"]
    s = s |> Enum.map(&String.graphemes/1)
    rules = input()

    for _ <- 1..2, reduce: s do
      acc ->
        acc
        |> tap(&IO.inspect/1)
        |> split()
        |> tap(&IO.inspect/1)
        |> replace(rules)
        |> tap(&IO.inspect/1)
        |> merge()
        |> tap(&IO.inspect/1)
        |> tap(fn x -> IO.puts("") end)
    end
  end

  def replace(lst, rules) do
    lst
    |> Enum.map(fn row ->
      row |> Enum.map(fn pattern -> rules[pattern] end)
    end)
  end

  def merge(lst) do
    lst
    |> Enum.map(fn each ->
      List.flatten(each)
    end)
  end

  def split(lst) do
    size = length(lst)

    split_size = if rem(size, 2) == 0, do: 2, else: 3

    grid =
      lst
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {row, i}, acc ->
        row
        |> Enum.with_index()
        |> Enum.reduce(acc, fn {c, j}, acc ->
          Map.put(acc, {i, j}, c)
        end)
      end)

    for i <- 0..(size - 1)//split_size, j <- 0..(size - 1)//split_size do
      for k <- 0..(split_size - 1) do
        grid[{i + k, j + k}]
      end
    end
  end

  def rotate(lst) do
    lst
    |> Enum.zip()
    |> Enum.map(fn x -> x |> Tuple.to_list() |> Enum.reverse() end)
  end

  def flip(lst) do
    lst |> Enum.map(&Enum.reverse/1)
  end

  def print(lst) do
    Enum.each(lst, fn x -> IO.inspect(Enum.join(x)) end)
    IO.puts("")
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
      |> String.replace(" ", "")
      |> String.split("=>")

    pattern = pattern |> s_to_lst()
    output = output |> s_to_lst()

    for _ <- 1..5, reduce: {%{}, pattern} do
      {acc, lst} ->
        acc =
          acc
          |> Map.put(lst, output)
          |> Map.put(flip(lst), output)

        {acc, rotate(lst)}
    end
    |> elem(0)
  end

  def s_to_lst(s) do
    s |> String.split("/") |> Enum.map(&String.graphemes/1)
  end
end
