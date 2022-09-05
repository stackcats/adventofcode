defmodule Solution do
  def part1() do
    input()
    |> parse_group(0, 0, 0)
    |> elem(0)
  end

  def part2() do
    input()
    |> parse_group(0, 0, 0)
    |> elem(1)
  end

  def parse_group([], _, score, chars), do: {score, chars}

  def parse_group([x | xs], level, score, chars) do
    case x do
      "{" ->
        parse_group(xs, level + 1, score, chars)

      "}" ->
        parse_group(xs, level - 1, score + level, chars)

      "<" ->
        {xs, chars} = parse_garbage(xs, chars)
        parse_group(xs, level, score, chars)

      _ ->
        parse_group(xs, level, score, chars)
    end
  end

  def parse_garbage([x | xs], chars) do
    case x do
      "!" -> xs |> tl() |> parse_garbage(chars)
      ">" -> {xs, chars}
      _ -> parse_garbage(xs, chars + 1)
    end
  end

  def input() do
    File.stream!("./input.txt")
    |> Enum.to_list()
    |> hd()
    |> String.trim()
    |> String.graphemes()
  end
end
