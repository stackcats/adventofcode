defmodule Solution do
  def part1() do
    aux("reyedfim", 0, "")
  end

  def aux(door_id, n, s) do
    if String.length(s) == 8 do
      s
    else
      hash =
        :crypto.hash(:md5, "#{door_id}#{n}")
        |> Base.encode16(case: :lower)

      if String.starts_with?(hash, "00000") do
        aux(door_id, n + 1, s <> String.slice(hash, 5, 1))
      else
        aux(door_id, n + 1, s)
      end
    end
  end

  def part2() do
    aux2("reyedfim", 0, %{})
    |> Enum.to_list()
    |> Enum.sort_by(&elem(&1, 0))
    |> Enum.map(&elem(&1, 1))
    |> Enum.join()
  end

  def aux2(door_id, n, m) do
    if map_size(m) == 8 do
      m
    else
      hash =
        :crypto.hash(:md5, "#{door_id}#{n}")
        |> Base.encode16(case: :lower)

      if String.starts_with?(hash, "00000") do
        pos = String.slice(hash, 5, 1)
        password = String.slice(hash, 6, 1)

        if Regex.match?(~r/[0-7]/, pos) do
          aux2(door_id, n + 1, Map.put_new(m, pos, password))
        else
          aux2(door_id, n + 1, m)
        end
      else
        aux2(door_id, n + 1, m)
      end
    end
  end
end
