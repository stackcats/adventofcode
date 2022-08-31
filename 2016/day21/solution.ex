defmodule Solution do
  @s "abcdefgh"

  def part1() do
    input()
    |> run(String.graphemes(@s))
  end

  def part2() do
    ops = input()

    @s
    |> String.graphemes()
    |> permutations()
    |> Enum.find(fn each -> run(ops, each) == "fbgdceah" end)
    |> Enum.join()
  end

  def run(ops, lst) do
    ops
    |> Enum.reduce(lst, &scrambling/2)
    |> Enum.join()
  end

  def scrambling(op, lst) do
    case op do
      ["swap", "position", a, "with", "position", b] ->
        a = String.to_integer(a)
        b = String.to_integer(b)

        lst
        |> List.replace_at(a, Enum.at(lst, b))
        |> List.replace_at(b, Enum.at(lst, a))

      ["swap", "letter", a, "with", "letter", b] ->
        lst
        |> Enum.map(fn c ->
          cond do
            c == a -> b
            c == b -> a
            true -> c
          end
        end)

      ["rotate", "left", a | _] ->
        a = String.to_integer(a)
        {left, right} = Enum.split(lst, a)
        right ++ left

      ["rotate", "right", a | _] ->
        a = String.to_integer(a)
        {left, right} = Enum.split(lst, length(lst) - a)
        right ++ left

      ["rotate", "based", "on", "position", "of", "letter", a] ->
        # TODO
        i = lst |> Enum.find_index(&(&1 == a))

        step = if i >= 4, do: i + 2, else: i + 1
        scrambling(["rotate", "right", "#{step}"], lst)

      ["reverse", "positions", a, "through", b] ->
        a = String.to_integer(a)
        b = String.to_integer(b)
        x = Enum.take(lst, a)
        y = Enum.slice(lst, a..b) |> Enum.reverse()
        z = Enum.drop(lst, b + 1)
        x ++ y ++ z

      ["move", "position", a, "to", "position", b] ->
        a = String.to_integer(a)
        b = String.to_integer(b)

        lst
        |> List.pop_at(a)
        |> then(fn {c, lst} ->
          lst |> List.insert_at(b, c)
        end)
    end
  end

  def permutations([]), do: [[]]

  def permutations(list),
    do: for(elem <- list, rest <- permutations(list -- [elem]), do: [elem | rest])

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.split/1)
    |> Enum.to_list()
  end
end
