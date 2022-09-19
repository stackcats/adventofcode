defmodule Solution do
  def part1() do
    input()
    |> run(0, %{}, 0)
  end

  def run(cmd, i, rs, mul_ct) do
    case cmd[i] do
      nil ->
        mul_ct

      ["set", x, y] ->
        y = get(rs, y)
        run(cmd, i + 1, Map.put(rs, x, y), mul_ct)

      ["sub", x, y] ->
        y = get(rs, y)

        run(cmd, i + 1, Map.update(rs, x, -y, &(&1 - y)), mul_ct)

      ["mul", x, y] ->
        y = get(rs, y)

        run(cmd, i + 1, Map.update(rs, x, 0, &(&1 * y)), mul_ct + 1)

      ["jnz", x, y] ->
        y = get(rs, y)

        if get(rs, x) == 0 do
          run(cmd, i + 1, rs, mul_ct)
        else
          run(cmd, i + y, rs, mul_ct)
        end
    end
  end

  def get(rs, x) do
    if Regex.match?(~r/-?\d+/, x) do
      String.to_integer(x)
    else
      rs[x] || 0
    end
  end

  def part2() do
    # Optimized Pseudo Code
    # b = 105700
    # c = 122700
    # while (b < c) (
    #   f = 1
    #   for (d = 2; d < b; d ++) {
    #     for (e = 2; e < b; e++) {
    #       if (d * e == b) f = 0
    #   }
    #   if (f == 0) {
    #     h += 1
    #   }
    #   b += 17
    # )
    for i <- 105_700..122_700//17, not is_prime(i), reduce: 0 do
      acc -> acc + 1
    end
  end

  def is_prime(2), do: true

  def is_prime(n) do
    sq = :math.sqrt(n) |> ceil()

    2..sq
    |> Enum.reduce_while(true, fn i, acc ->
      if rem(n, i) == 0 do
        {:halt, false}
      else
        {:cont, acc}
      end
    end)
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.split(&1, " "))
    |> Enum.to_list()
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {c, i}, acc ->
      Map.put(acc, i, c)
    end)
  end
end
