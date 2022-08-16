defmodule Solution do
  @target %{
    "children" => 3,
    "cats" => 7,
    "samoyeds" => 2,
    "pomeranians" => 3,
    "akitas" => 0,
    "vizslas" => 0,
    "goldfish" => 5,
    "trees" => 3,
    "cars" => 2,
    "perfumes" => 1
  }

  def part1() do
    input()
    |> Enum.reduce_while(-1, fn {no, compounds}, ans ->
      if Enum.all?(compounds, fn {k, v} -> @target[k] == v end) do
        {:halt, no}
      else
        {:cont, ans}
      end
    end)
  end

  def part2() do
    input()
    |> Enum.reduce_while(-1, fn {no, compounds}, ans ->
      is_match =
        Enum.all?(compounds, fn {k, v} ->
          cond do
            k == "cats" || k == "trees" -> v > @target[k]
            k == "pomeranians" || k == "goldfish" -> v < @target[k]
            true -> v == @target[k]
          end
        end)

      if is_match do
        {:halt, no}
      else
        {:cont, ans}
      end
    end)
  end

  def input() do
    # Sue 18: children: 9, goldfish: 2, akitas: 10
    reg =
      ~r/Sue (?<no>([0-9]+)): (?<n1>[^:]+): (?<v1>[0-9]+), (?<n2>[^:]+): (?<v2>[0-9]+), (?<n3>[^:]+): (?<v3>[0-9]+)/

    File.stream!("./input.txt")
    |> Stream.map(fn s ->
      Regex.named_captures(reg, s)
    end)
    |> Stream.map(fn m ->
      compounds =
        %{}
        |> Map.put(m["n1"], String.to_integer(m["v1"]))
        |> Map.put(m["n2"], String.to_integer(m["v2"]))
        |> Map.put(m["n3"], String.to_integer(m["v3"]))

      {String.to_integer(m["no"]), compounds}
    end)
    |> Enum.to_list()
  end
end
