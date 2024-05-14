defmodule Solution do
  def part1() do
    run(["~", "|"])
  end

  def part2() do
    run(["~"])
  end

  def run(targets) do
    mp = input()
    {min_y, max_y} = mp |> Map.keys() |> Enum.map(&elem(&1, 0)) |> Enum.min_max()

    flow(mp, {0, 500}, max_y)
    |> Enum.count(fn {{y, _}, v} -> y in min_y..max_y and v in targets end)
  end

  def flow(mp, {y, _x}, max_y) when y + 1 > max_y, do: mp

  def flow(mp, curr, max_y) do
    mp
    |> flow_v(curr, max_y)
    |> flow_h(curr, -1, max_y)
    |> flow_h(curr, 1, max_y)
    |> then(fn mp ->
      if has_wall?(mp, curr, -1) and has_wall?(mp, curr, 1) do
        mp |> fill(curr, -1) |> fill(curr, 1)
      else
        mp
      end
    end)
  end

  def flow_v(mp, {y, x}, max_y) do
    down = {y + 1, x}

    if mp[down] == nil do
      Map.put(mp, down, "|") |> flow(down, max_y)
    else
      mp
    end
  end

  def flow_h(mp, {y, x}, dx, max_y) do
    next = {y, x + dx}

    if mp[{y + 1, x}] in ["#", "~"] and mp[next] == nil do
      Map.put(mp, next, "|") |> flow(next, max_y)
    else
      mp
    end
  end

  def fill(mp, {y, x} = curr, dx) do
    if mp[curr] == "#" do
      mp
    else
      mp |> Map.put(curr, "~") |> fill({y, x + dx}, dx)
    end
  end

  def has_wall?(mp, {y, x}, dx) do
    cond do
      mp[{y, x + dx}] == "#" -> true
      mp[{y, x + dx}] == nil -> false
      mp[{y + 1, x}] not in ["#", "~"] -> false
      true -> has_wall?(mp, {y, x + dx}, dx)
    end
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(fn s ->
      [p, l, r] =
        Regex.scan(~r/\d+/, s)
        |> Enum.flat_map(fn x -> x |> Enum.map(&String.to_integer/1) end)

      if String.starts_with?(s, "x"), do: {l..r, p..p}, else: {p..p, l..r}
    end)
    |> Enum.reduce(%{}, fn {ys, xs}, acc ->
      for y <- ys, x <- xs, reduce: acc do
        acc ->
          Map.put(acc, {y, x}, "#")
      end
    end)
  end
end
