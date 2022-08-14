defmodule Solution do
  def nice_strings() do
    File.stream!("./input.txt")
    |> Stream.filter(&(not Regex.match?(~r/(ab|cd|pq|xy)/, &1)))
    |> Stream.filter(&Regex.match?(~r/[aeiou].*[aeiou].*[aeiou]/, &1))
    |> Stream.filter(&Regex.match?(~r/(.)\1/, &1))
    |> Enum.to_list()
    |> Enum.count()
  end

  def new_rule_nice_strings() do
    File.stream!("./input.txt")
    |> Stream.filter(&Regex.match?(~r/(..).*\1/, &1))
    |> Stream.filter(&Regex.match?(~r/(.).\1/, &1))
    |> Enum.to_list()
    |> Enum.count()
  end
end
