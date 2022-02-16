defmodule Solution do
  def part1() do
    input()
    |> Enum.reduce(0, fn {a, b, c, d}, acc ->
      ct =
        d
        |> String.graphemes()
        |> Enum.reduce(%{}, fn c, m ->
          Map.update(m, c, 1, &(&1 + 1))
        end)
        |> Map.get(c)

      if ct >= a and ct <= b, do: acc + 1, else: acc
    end)
  end

  def part2() do
    input()
    |> Enum.reduce(0, fn {a, b, c, d}, acc ->
      m =
        d
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.reduce(%{}, fn {c, i}, m ->
          Map.put(m, i + 1, c)
        end)

      cond do
        m[a] == c && m[b] == c -> acc
        m[a] == c || m[b] == c -> acc + 1
        true -> acc
      end
    end)
  end

  defp input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&parse/1)
    |> Enum.to_list()
  end

  defp parse(s) do
    m =
      ~r/(?<a>\d*)-(?<b>\d*) (?<c>[a-z]*): (?<d>[a-z]*)/
      |> Regex.named_captures(s)
      |> Enum.into(%{})
      |> Map.update!("a", &String.to_integer/1)
      |> Map.update!("b", &String.to_integer/1)

    {m["a"], m["b"], m["c"], m["d"]}
  end
end
