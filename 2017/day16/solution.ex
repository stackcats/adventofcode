defmodule Solution do
  def part1() do
    input()
    |> Enum.reduce(
      ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p"],
      fn cmd, acc ->
        case cmd do
          {"s", x} ->
            acc

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
    |> List.replace_at(b, Enum.at(a))
  end

  def swap(lst, x, y) do
    a = Enum.find_index(lst, x)
    b = Enum.find_index(lst, y)
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
