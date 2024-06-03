defmodule Solution do
  def part1() do
    {ranges, _tickets, nearby} = input()

    nearby
    |> List.flatten()
    |> Enum.filter(fn n ->
      Enum.all?(ranges, fn {_, f} -> not f.(n) end)
    end)
    |> Enum.sum()
  end

  def part2() do
    {ranges, tickets, nearby} = input()

    valids =
      nearby
      |> Enum.filter(fn ns ->
        ns
        |> Enum.all?(fn n ->
          Enum.any?(ranges, fn {_, f} -> f.(n) end)
        end)
      end)
      |> Enum.zip()
      |> Enum.map(&Tuple.to_list/1)
      |> Enum.with_index()

    ranges
    |> Enum.map(fn {_, f} ->
      valids
      |> Enum.filter(fn {lst, _} -> Enum.all?(lst, f) end)
      |> Enum.map(&elem(&1, 1))
    end)
    |> Enum.with_index()
    |> Map.new(fn {k, i} -> {i, k} end)
    |> run(%{})
    |> Enum.map(fn {k, v} ->
      {t, _} = Enum.at(ranges, k)
      if t == "departure", do: Enum.at(tickets, v), else: 1
    end)
    |> Enum.product()
  end

  def run(mp, res) when map_size(mp) == 0, do: res

  def run(mp, res) do
    {k, [t]} = mp |> Enum.find(fn {_, v} -> length(v) == 1 end)

    mp
    |> Map.new(fn {k, v} ->
      {k, List.delete(v, t)}
    end)
    |> Map.filter(fn {_, v} -> v != [] end)
    |> run(Map.put(res, k, t))
  end

  def input() do
    [sec1, sec2, sec3] = File.read!("./input.txt") |> String.split("\n\n")

    ranges = parse_sec1(sec1)

    tickets = parse_tickets(sec2) |> hd()

    nearby = parse_tickets(sec3)

    {ranges, tickets, nearby}
  end

  def parse_sec1(s) do
    s
    |> String.split("\n")
    |> Enum.map(fn r ->
      type = r |> String.split(" ") |> hd()

      [a, b, c, d] =
        Regex.scan(~r/\d+/, r)
        |> Enum.map(fn [n] -> String.to_integer(n) end)

      {type, fn n -> n in a..b or n in c..d end}
    end)
  end

  def parse_tickets(s) do
    s
    |> String.trim()
    |> String.split("\n")
    |> Enum.drop(1)
    |> Enum.map(fn r ->
      r |> String.split(",") |> Enum.map(&String.to_integer/1)
    end)
  end
end
