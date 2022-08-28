defmodule Solution do
  def part1() do
    aux(0, "ahsbgdzn", 0)
  end

  def aux(i, salt, n) do
    if key?(salt, i) do
      if n + 1 == 64 do
        i
      else
        aux(i + 1, salt, n + 1)
      end
    else
      aux(i + 1, salt, n)
    end
  end

  def key?(salt, i) do
    r3 = ~r/(?<c>.)\1{2}/
    cap = Regex.named_captures(r3, key(salt, i))

    if cap == nil do
      false
    else
      r5 = Regex.compile!("(#{cap["c"]})\\1{4}")

      Enum.any?(1..1000, fn x ->
        Regex.match?(r5, key(salt, i + x))
      end)
    end
  end

  def key(salt, i) do
    :crypto.hash(:md5, "#{salt}#{i}")
    |> Base.encode16(case: :lower)
  end
end
