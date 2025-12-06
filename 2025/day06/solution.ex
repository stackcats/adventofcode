defmodule Solution do
  def part1() do
    {worksheet, ops} = input()

    worksheet
    |> delete_last()
    |> to_ints()
    |> transpose()
    |> calc(ops)
  end

  def part2() do
    {worksheet, ops} = input()

    worksheet
    |> rotate()
    |> to_ints()
    |> calc(Enum.reverse(ops))
  end

  def to_ints(lst) do
    Enum.map(lst, fn s ->
      String.split(s, " ", trim: true)
      |> Enum.map(&String.to_integer/1)
    end)
  end

  def delete_last(lst) do
    lst
    |> Enum.reverse()
    |> tl()
    |> Enum.reverse()
  end

  def transpose(mat) do
    mat
    |> Enum.zip()
    |> Enum.map(&Tuple.to_list/1)
  end

  def rotate(mat) do
    mat
    |> Enum.map(&String.graphemes/1)
    |> Enum.zip()
    |> Enum.reverse()
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.map(&Enum.join/1)
    |> Enum.join()
    |> String.split(~r/(\+|\*)/)
  end

  def calc(worksheet, ops) do
    Enum.zip(worksheet, ops)
    |> Enum.map(fn
      {lst, "+"} -> Enum.sum(lst)
      {lst, "*"} -> Enum.product(lst)
    end)
    |> Enum.sum()
  end

  def input() do
    worksheet = File.read!("./input.txt") |> String.split("\n", trim: true)
    ops = List.last(worksheet) |> String.split(" ", trim: true)
    {worksheet, ops}
  end
end
