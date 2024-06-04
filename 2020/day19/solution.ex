defmodule Solution do
  def part1() do
    {rules, messages} = input()

    messages
    |> Enum.count(fn m -> run(rules, ["0"], m) end)
  end

  def part2() do
    {rules, messages} = input()
    re = %{"8" => [["42"], ["42", "8"]], "11" => [["42", "31"], ["42", "11", "31"]]}

    messages
    |> Enum.count(fn m -> run(Map.merge(rules, re), ["0"], m) end)
  end

  def run(_, [], []), do: true
  def run(_, [], _), do: false
  def run(_, _, []), do: false

  def run(rules, [x | xs], s) do
    rule = rules[x]

    cond do
      is_list(rule) -> Enum.any?(rule, fn r -> run(rules, r ++ xs, s) end)
      rule == hd(s) -> run(rules, xs, tl(s))
      true -> false
    end
  end

  def input() do
    [rules, messages] = File.read!("./input.txt") |> String.split("\n\n")
    {parse_rules(rules), parse_message(messages)}
  end

  def parse_rules(rules) do
    rules
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn s ->
      [id, rule] = s |> String.split(": ")

      if String.contains?(rule, "\"") do
        String.replace(rule, "\"", "")
      else
        rule
        |> String.split(" | ")
        |> Enum.map(&String.split(&1, " "))
      end
      |> then(fn rule -> {id, rule} end)
    end)
    |> Map.new()
  end

  def parse_message(messages) do
    messages |> String.trim() |> String.split("\n") |> Enum.map(&String.graphemes/1)
  end
end
