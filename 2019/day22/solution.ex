defmodule Solution do
  require Integer

  # https://www.reddit.com/r/adventofcode/comments/ee0rqi/comment/fbnkaju/

  def part1() do
    {offset, increment} = shuffle(10007, 1)
    0..deck_size |> Enum.find(fn n -> Integer.mod(offset + increment * n, deck_size) == 2019 end)
  end

  def part2() do
    deck_size = 119_315_717_514_047
    iterations = 101_741_582_076_661
    {offset, increment} = shuffle(deck_size, iterations)
    Integer.mod(offset + increment * 2020, deck_size)
  end

  def shuffle(deck_size, iterations) do
    input()
    |> Enum.reduce({0, 1}, fn
      {:cut, n}, {offset_diff, increment_mul} ->
        offset_diff = Integer.mod(offset_diff + increment_mul * n, deck_size)
        {offset_diff, increment_mul}

      :rev, {offset_diff, increment_mul} ->
        increment_mul = Integer.mod(-increment_mul, deck_size)
        offset_diff = Integer.mod(offset_diff + increment_mul, deck_size)
        {offset_diff, increment_mul}

      {:inc, n}, {offset_diff, increment_mul} ->
        increment_mul =
          modinv(n, deck_size) |> then(&(&1 * increment_mul)) |> Integer.mod(deck_size)

        {offset_diff, increment_mul}
    end)
    |> then(fn {offset_diff, increment_mul} ->
      increment = expmod(increment_mul, iterations, deck_size)

      offset =
        offset_diff * (1 - increment) *
          (Integer.mod(1 - increment_mul, deck_size) |> modinv(deck_size))

      {offset, increment}
    end)
  end

  def modinv(a, m) do
    {_g, x, _y} = Integer.extended_gcd(a, m)
    Integer.mod(x, m)
  end

  def expmod(_base, 0, _mod), do: 1

  def expmod(base, exp, mod) when Integer.is_even(exp) do
    expmod(base, div(exp, 2), mod) |> Integer.pow(2) |> Integer.mod(mod)
  end

  def expmod(base, exp, mod) do
    Integer.mod(base * expmod(base, exp - 1, mod), mod)
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(fn s ->
      case String.split(s, " ") do
        ["cut", n] -> {:cut, String.to_integer(n)}
        ["deal", "into" | _] -> :rev
        ["deal", "with", "increment", n] -> {:inc, String.to_integer(n)}
      end
    end)
  end
end
