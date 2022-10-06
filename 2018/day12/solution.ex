defmodule Solution do
  @init_state "#...#..##.......####.#..###..#.##..########.#.#...#.#...###.#..###.###.#.#..#...#.#..##..#######.##"

  def part1() do
    combs = input()

    for _ <- 1..20, reduce: init() do
      acc -> next_generation(acc, combs)
    end
    |> sum()
  end

  def part2() do
    combs = input()
    state = init()

    # Find the pattern of generations
    # The `sum` will increase by constant
    for _ <- 1..1000, reduce: {state, 0, 0} do
      {acc, pre_sum, diff} ->
        acc = next_generation(acc, combs)
        ct = sum(acc)
        {acc, ct, ct - pre_sum}
    end
    |> then(fn {_, pre_sum, diff} ->
      pre_sum + (50_000_000_000 - 1000) * diff
    end)
  end

  def sum(state) do
    state
    |> Map.keys()
    |> Enum.sum()
  end

  def next_generation(state, combs) do
    {mi, ma} = state |> Map.keys() |> Enum.min_max()

    for i <- (mi - 2)..(ma + 2), reduce: %{} do
      acc ->
        for j <- (i - 2)..(i + 2), into: "" do
          Map.get(state, j, ".")
        end
        |> then(fn s ->
          if combs[s] == "#", do: Map.put(acc, i, "#"), else: acc
        end)
    end
  end

  def init() do
    @init_state
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {c, i}, acc ->
      Map.put(acc, i, c)
    end)
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(fn s ->
      s
      |> String.split(" => ")
      |> List.to_tuple()
    end)
    |> Map.new()
  end
end
