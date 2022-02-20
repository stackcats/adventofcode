defmodule Solution do
  @fields ["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"]
  def part1() do
    input()
    |> Enum.count(fn m ->
      Enum.all?(@fields, &Map.has_key?(m, &1))
    end)
  end

  def part2() do
    input()
    |> Enum.count(&is_valid?(&1))
  end

  def is_valid?(passport) do
    [
      {~r/^(19[2-9][0-9])|(200[0-2])$/, "byr"},
      {~r/^(201[0-9])|(2020)$/, "iyr"},
      {~r/^(202[0-9])|(2030)$/, "eyr"},
      {~r/^(((1[5-8][0-9])|(19[0-3]))cm)|(((59)|(6[0-9])|(7[0-6]))in)$/, "hgt"},
      {~r/^#[0-9a-f]{6}$/, "hcl"},
      {~r/^(amb)|(blu)|(brn)|(gry)|(grn)|(hzl)|(oth)$/, "ecl"},
      {~r/^[0-9]{9}$/, "pid"}
    ]
    |> Enum.all?(fn {r, k} -> Regex.match?(r, Map.get(passport, k, "")) end)
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.chunk_by(&(&1 == ""))
    |> Stream.filter(&(&1 != [""]))
    |> Stream.map(&Enum.join(&1, " "))
    |> Stream.map(&String.split/1)
    |> Stream.map(
      &Enum.reduce(&1, %{}, fn s, acc ->
        [k, v] = String.split(s, ":")
        Map.put(acc, k, v)
      end)
    )
    |> Enum.to_list()
  end
end
