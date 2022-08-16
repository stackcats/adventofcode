defmodule Solution do
  def part1() do
    next_password("hepxcrrq")
  end

  def part2() do
    next_password("hepxxyzz")
  end

  def next_password(s) do
    ns = add1(s)

    if r1(ns) && r2(ns) && r3(ns) do
      ns
    else
      next_password(ns)
    end
  end

  def add1(cs) do
    cs
    |> String.to_charlist()
    |> Enum.reverse()
    |> add1([])
    |> List.to_string()
  end

  def add1([], ans) do
    ans
  end

  def add1([c | cs], ans) do
    if c == ?z do
      add1(cs, [?a | ans])
    else
      Enum.reverse(cs) ++ [c + 1 | ans]
    end
  end

  def r1(s) do
    increasing_list()
    |> Enum.any?(fn patten ->
      String.contains?(s, patten)
    end)
  end

  def r2(s) do
    not String.contains?(s, ["i", "o", "l"])
  end

  def r3(s) do
    pairs_list()
    |> Enum.any?(fn [aa, bb] ->
      String.contains?(s, aa) && String.contains?(s, bb)
    end)
  end

  def increasing_list() do
    for c <- ?a..?x do
      List.to_string([c, c + 1, c + 2])
    end
  end

  def pairs_list() do
    lst =
      for c <- ?a..?z do
        List.to_string([c, c])
      end

    for a <- lst, b <- lst, a != b do
      [a, b]
    end
  end
end
