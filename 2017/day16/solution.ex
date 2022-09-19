defmodule Solution do
  @init ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p"]

  def part1() do
    @init
    |> dance(input())
    |> Enum.join()
  end

  def part2() do
    moves = input()

    # find repeated size
    len =
      1..1_000_000_000
      |> Enum.reduce_while({@init, MapSet.new()}, fn _, {acc, set} ->
        if MapSet.member?(set, acc) do
          {:halt, {acc, set}}
        else
          {:cont, {dance(acc, moves), MapSet.put(set, acc)}}
        end
      end)
      |> elem(1)
      |> MapSet.size()

    for _ <- 1..rem(1_000_000_000, len), reduce: @init do
      acc -> dance(acc, moves)
    end
    |> Enum.join()
  end

  def dance(lst, moves) do
    moves
    |> Enum.reduce(
      lst,
      fn cmd, acc ->
        case cmd do
          {"s", x} ->
            {f, r} = Enum.split(acc, 16 - x)
            r ++ f

          {"x", [a, b]} ->
            swap_by_position(acc, a, b)

          {"p", [a, b]} ->
            swap(acc, a, b)
        end
      end
    )
  end

  def swap_by_position(lst, a, b) do
    lst
    |> List.replace_at(a, Enum.at(lst, b))
    |> List.replace_at(b, Enum.at(lst, a))
  end

  def swap(lst, x, y) do
    a = Enum.find_index(lst, &(&1 == x))
    b = Enum.find_index(lst, &(&1 == y))
    swap_by_position(lst, a, b)
  end

  def input() do
    File.stream!("./input.txt")
    |> Enum.to_list()
    |> hd()
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&parse/1)
  end

  def parse(s) do
    {s, r} = String.split_at(s, 1)

    case s do
      "s" -> r |> String.to_integer()
      "x" -> r |> String.split("/") |> Enum.map(&String.to_integer/1)
      "p" -> r |> String.split("/")
    end
    |> then(fn r ->
      {s, r}
    end)
  end
end
