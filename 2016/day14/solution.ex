defmodule Solution do
  @salt "ahsbgdzn"

  def part1() do
    aux(0, @salt, 0, %{})
  end

  def part2() do
    aux(0, @salt, 0, %{}, true)
  end

  def aux(i, salt, n, map, stretch? \\ false) do
    case key?(salt, i, map, stretch?) do
      {true, map} ->
        if n + 1 == 64 do
          i
        else
          aux(i + 1, salt, n + 1, map, stretch?)
        end

      {false, map} ->
        aux(i + 1, salt, n, map, stretch?)
    end
  end

  def key?(salt, i, map, stretch? \\ false) do
    r3 = ~r/(?<c>.)\1{2}/
    {k, map} = key(salt, i, map, stretch?)
    cap = Regex.named_captures(r3, k)

    if cap == nil do
      {false, map}
    else
      r5 = Regex.compile!("(#{cap["c"]})\\1{4}")

      1..1000
      |> Enum.reduce_while({false, map}, fn x, {_, map} ->
        {k, map} = key(salt, i + x, map, stretch?)

        if Regex.match?(r5, k) do
          {:halt, {true, map}}
        else
          {:cont, {false, map}}
        end
      end)
    end
  end

  def key(salt, i, map, stretch? \\ false) do
    if Map.has_key?(map, i) do
      {map[i], map}
    else
      key0 = :crypto.hash(:md5, "#{salt}#{i}") |> Base.encode16(case: :lower)
      key = if stretch?, do: stretch(key0), else: key0
      {key, Map.put(map, i, key)}
    end
  end

  def stretch(s) do
    1..2016
    |> Enum.reduce(s, fn _, s ->
      :crypto.hash(:md5, s) |> Base.encode16(case: :lower)
    end)
  end
end
