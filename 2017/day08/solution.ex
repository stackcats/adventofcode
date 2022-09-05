defmodule Solution do
  def part1() do
    input()
    |> Enum.reduce(%{}, fn {r, cmd, offset, cr, f, v}, acc ->
      if f.(Map.get(acc, cr, 0), v) do
        case cmd do
          "inc" -> Map.update(acc, r, offset, &(&1 + offset))
          _ -> Map.update(acc, r, -offset, &(&1 - offset))
        end
      else
        acc
      end
    end)
    |> Map.values()
    |> Enum.max()
  end

  def part2() do
    input()
    |> Enum.reduce({%{}, 0}, fn {r, cmd, offset, cr, f, v}, {acc, highest} ->
      acc =
        if f.(Map.get(acc, cr, 0), v) do
          case cmd do
            "inc" -> Map.update(acc, r, offset, &(&1 + offset))
            _ -> Map.update(acc, r, -offset, &(&1 - offset))
          end
        else
          acc
        end

      {acc, max(acc[r] || 0, highest)}
    end)
    |> elem(1)
  end

  def cmp(cd) do
    case cd do
      ">" -> &>/2
      "<" -> &</2
      ">=" -> &>=/2
      "<=" -> &<=/2
      "==" -> &==/2
      "!=" -> &!=/2
    end
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(fn s ->
      ~r/(?<r>[a-z]+) (?<cmd>[a-z]+) (?<offset>[-0-9]+) if (?<cr>[a-z]+) (?<cd>[!<=>]+) (?<v>[-0-9]+)/
      |> Regex.named_captures(s)
      |> then(fn m ->
        {m["r"], m["cmd"], String.to_integer(m["offset"]), m["cr"], cmp(m["cd"]),
         String.to_integer(m["v"])}
      end)
    end)
    |> Enum.to_list()
  end
end
