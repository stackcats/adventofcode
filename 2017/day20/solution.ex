defmodule Solution do
  def part1() do
    lst = input() |> Enum.with_index()

    for _ <- 1..500, reduce: lst do
      acc ->
        acc
        |> Enum.map(fn {{p, v, a}, i} ->
          v = add(v, a)
          p = add(p, v)
          {{p, v, a}, i}
        end)
    end
    |> Enum.min_by(fn {{[x, y, z], _, _}, _} ->
      abs(x) + abs(y) + abs(z)
    end)
    |> elem(1)
  end

  def part2() do
    lst = input()

    for _ <- 1..500, reduce: lst do
      acc ->
        acc
        |> Enum.reduce({[], %{}}, fn {p, v, a}, {acc, map} ->
          v = add(v, a)
          p = add(p, v)
          {[{p, v, a} | acc], Map.update(map, p, 1, &(&1 + 1))}
        end)
        |> then(fn {acc, map} ->
          acc |> Enum.filter(fn {p, _, _} -> map[p] == 1 end)
        end)
    end
    |> length()
  end

  def add([a, b, c], [x, y, z]) do
    [a + x, b + y, c + z]
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(fn s ->
      ~r/p=<(?<p>.+)>, v=<(?<v>.+)>, a=<(?<a>.*)>/
      |> Regex.named_captures(s)
      |> then(fn cap ->
        {v_to_tuple(cap["p"]), v_to_tuple(cap["v"]), v_to_tuple(cap["a"])}
      end)
    end)
    |> Enum.to_list()
  end

  def v_to_tuple(s) do
    s |> String.split(",") |> Enum.map(&String.to_integer/1)
  end
end
