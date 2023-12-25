defmodule Solution do
  def part1() do
    {v, e} = input()

    karger(v, e)
    |> Enum.map(&MapSet.size/1)
    |> Enum.product()
  end

  def karger(v, e) do
    {[s1, s2], remained_e} = contract(v, e)

    Enum.count(remained_e, fn {a, b} ->
      (MapSet.member?(s1, a) && MapSet.member?(s2, b)) ||
        (MapSet.member?(s1, b) && MapSet.member?(s2, a))
    end)
    |> then(fn ct ->
      if ct == 3, do: [s1, s2], else: karger(v, e)
    end)
  end

  def contract(v, e) do
    if MapSet.size(v) > 2 do
      {a, b} = Enum.random(e)
      e = MapSet.delete(e, {a, b})
      s1 = v |> Enum.find(fn s -> MapSet.member?(s, a) end)
      s2 = v |> Enum.find(fn s -> MapSet.member?(s, b) end)
      s3 = MapSet.union(s1, s2)

      v
      |> MapSet.delete(s1)
      |> MapSet.delete(s2)
      |> MapSet.put(s3)
      |> contract(e)
    else
      {MapSet.to_list(v), e}
    end
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(fn s -> Regex.scan(~r/([a-z]{3})/, s) |> Enum.map(&hd/1) end)
    |> Enum.reduce({%MapSet{}, %MapSet{}}, fn [l | rs] = lst, {v, e} ->
      v = MapSet.new(lst, fn x -> MapSet.new([x]) end) |> MapSet.union(v)
      e = MapSet.new(rs, fn r -> {l, r} end) |> MapSet.union(e)
      {v, e}
    end)
  end
end
