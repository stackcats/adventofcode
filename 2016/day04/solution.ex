defmodule Solution do
  def part1() do
    input()
    |> Enum.reduce(0, fn s, acc ->
      case real_room(s) do
        {true, n, _} -> acc + n
        _ -> acc
      end
    end)
  end

  def part2() do
    input()
    |> Enum.flat_map(fn s ->
      case real_room(s) do
        {true, n, t} -> [{n, decrypt(t, n)}]
        _ -> []
      end
    end)
    |> Enum.find(fn {_, s} -> String.starts_with?(s, "northpole") end)
    |> elem(0)
  end

  def decrypt(s, n) do
    s
    |> String.graphemes()
    |> Enum.map(fn c ->
      if c == "-", do: " ", else: add(c, n)
    end)
    |> Enum.join()
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Enum.to_list()
  end

  def real_room(s) do
    s
    |> String.split("-")
    |> real_room(%{}, String.replace(s, ~r/-\d+\[.*\]/, ""))
  end

  def real_room([x], ct, s) do
    [n, checksum, _] = String.split(x, ["[", "]"])

    encrypted =
      ct
      |> Enum.to_list()
      |> Enum.sort_by(fn {k, v} -> {-v, k} end)
      |> Enum.take(5)
      |> Enum.map(fn {k, _} -> k end)
      |> Enum.join()

    {checksum == encrypted, String.to_integer(n), s}
  end

  def real_room([x | xs], ct, s) do
    x
    |> String.graphemes()
    |> Enum.reduce(ct, fn c, acc ->
      Map.update(acc, c, 1, &(&1 + 1))
    end)
    |> then(&real_room(xs, &1, s))
  end

  def add(s, n) do
    n = rem(n, 26)
    code = :binary.first(s)

    if code + n > ?z do
      ?a + code + n - ?z - 1
    else
      code + n
    end
    |> then(&List.to_string([&1]))
  end
end
