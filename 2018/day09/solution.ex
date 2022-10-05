defmodule Solution do
  @marbles 71240
  @players 478

  def part1() do
    run(:queue.from_list([0]), %{}, 0, 1, @marbles)
  end

  def part2() do
    run(:queue.from_list([0]), %{}, 0, 1, @marbles * 100)
  end

  def run(_q, scores, _p, marble, last_marble) when marble > last_marble do
    scores
    |> Map.values()
    |> Enum.max()
  end

  def run(q, scores, p, marble, last_marble) do
    if rem(marble, 23) == 0 do
      q = rotate(q, 7)
      {{:value, m}, q} = :queue.out_r(q)
      scores = Map.update(scores, p, marble + m, &(&1 + marble + m))

      q
      |> rotate(-1)
      |> run(scores, rem(p + 1, @players), marble + 1, last_marble)
    else
      q
      |> rotate(-1)
      |> :queue.snoc(marble)
      |> run(scores, rem(p + 1, @players), marble + 1, last_marble)
    end
  end

  def rotate(q, n) when n < 0 do
    for _ <- -1..n, reduce: q do
      q ->
        {{:value, item}, q} = :queue.out(q)
        :queue.in(item, q)
    end
  end

  def rotate(q, n) do
    for _ <- 1..n, reduce: q do
      q ->
        {{:value, item}, q} = :queue.out_r(q)
        :queue.in_r(item, q)
    end
  end
end
