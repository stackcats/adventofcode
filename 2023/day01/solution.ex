defmodule Solution do
  def part1() do
    input()
    |> Enum.map(&String.replace(&1, ~r/[^0-9]/, ""))
    |> Enum.reduce(0, fn s, acc ->
      first_digit = String.first(s) |> String.to_integer()
      last_digit = String.last(s) |> String.to_integer()
      acc + first_digit * 10 + last_digit
    end)
  end

  def part2() do
    input()
    |> Enum.reduce(0, fn s, acc ->
      pattern = "one|two|three|four|five|six|seven|eight|nine"

      first_digit = Regex.run(~r/(#{pattern}|\d)/, s) |> hd() |> to_digit()

      last_digit =
        Regex.run(~r/(#{String.reverse(pattern)}|\d)/, String.reverse(s))
        |> hd()
        |> String.reverse()
        |> to_digit()

      acc + first_digit * 10 + last_digit
    end)
  end

  def to_digit(s) do
    %{
      "one" => "1",
      "two" => "2",
      "three" => "3",
      "four" => "4",
      "five" => "5",
      "six" => "6",
      "seven" => "7",
      "eight" => "8",
      "nine" => "9"
    }
    |> Map.get(s, s)
    |> String.to_integer()
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Enum.to_list()
  end
end
