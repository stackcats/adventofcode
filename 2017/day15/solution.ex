defmodule Solution do
  use Bitwise

  @a 289
  @b 629

  def part1() do
    for _ <- 1..40_000_000, reduce: {0, @a, @b} do
      {ct, a, b} ->
        a = ga(a)
        b = gb(b)

        if match(a, b) do
          {ct + 1, a, b}
        else
          {ct, a, b}
        end
    end
    |> elem(0)
  end

  def part2() do
    for _ <- 1..5_000_000, reduce: {0, @a, @b} do
      {ct, a, b} ->
        a = ga(a, 4)
        b = gb(b, 8)

        if match(a, b) do
          {ct + 1, a, b}
        else
          {ct, a, b}
        end
    end
    |> elem(0)
  end

  def match(a, b) do
    band(a, 0xFFFF) == band(b, 0xFFFF)
  end

  def ga(n, r \\ 1) do
    n = generate(n, 16807)

    if rem(n, r) == 0 do
      n
    else
      ga(n, r)
    end
  end

  def gb(n, r \\ 1) do
    n = generate(n, 48271)

    if rem(n, r) == 0 do
      n
    else
      gb(n, r)
    end
  end

  def generate(n, factor) do
    rem(n * factor, 2_147_483_647)
  end
end
