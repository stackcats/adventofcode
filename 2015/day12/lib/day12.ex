defmodule Day12 do
  def part1() do
    input()
    |> parse(0, false)
  end

  def part2() do
    input()
    |> parse(0, true)
  end

  def parse(obj, acc, check_red?) do
    cond do
      is_number(obj) ->
        acc + obj

      is_map(obj) ->
        if check_red? && has_red?(obj) do
          acc
        else
          Map.values(obj)
          |> Enum.reduce(acc, fn v, acc ->
            parse(v, acc, check_red?)
          end)
        end

      is_list(obj) ->
        Enum.reduce(obj, acc, fn
          v, acc ->
            parse(v, acc, check_red?)
        end)

      true ->
        acc
    end
  end

  def has_red?(obj) do
    Map.values(obj) |> MapSet.new() |> MapSet.member?("red")
  end

  def input do
    with {:ok, content} <- File.read("./input.json"),
         {:ok, map} <- Jason.decode!(content) do
      map
    end
  end
end
