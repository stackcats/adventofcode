defmodule Solution do
  def part1() do
    rounds = MapSet.new([20, 60, 100, 140, 180, 220])

    input()
    |> Enum.reduce({1, 1, 0}, fn c, {v, rnd, acc} ->
      case c do
        :noop ->
          rnd = rnd + 1

          if rnd in rounds do
            {v, rnd, acc + rnd * v}
          else
            {v, rnd, acc}
          end

        {:addx, n} ->
          rnd = rnd + 2

          cond do
            (rnd - 1) in rounds ->
              {v + n, rnd, acc + (rnd - 1) * v}

            rnd in rounds ->
              {v + n, rnd, acc + rnd * (v + n)}

            true ->
              {v + n, rnd, acc}
          end
      end
    end)
  end

  def part2() do
    input()
    |> Enum.reduce({0, %{}, 1}, fn c, {crt_pos, crt, v} ->
      case c do
        :noop ->
          {crt_pos, crt} = draw(crt_pos, crt, v)
          {crt_pos, crt, v}

        {:addx, n} ->
          {crt_pos, crt} = draw(crt_pos, crt, v)
          {crt_pos, crt} = draw(crt_pos, crt, v)
          {crt_pos, crt, v + n}
      end
    end)
    |> elem(1)
    |> print()
  end

  def print(crt) do
    for i <- 0..5 do
      for j <- 0..39, do: crt[{i, j}]
    end
    |> Enum.join("\n")
    |> IO.puts()
  end

  def draw(pos, crt, v) do
    r = div(pos, 40)
    c = rem(pos, 40)
    pixel = if c in [v - 1, v, v + 1], do: '#', else: '.'
    crt = Map.put(crt, {r, c}, pixel)
    {pos + 1, crt}
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Enum.map(fn s ->
      if s == "noop" do
        :noop
      else
        [_, n] = String.split(s, " ")
        {:addx, String.to_integer(n)}
      end
    end)
  end
end
