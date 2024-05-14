defmodule Solution do
  def part1() do
    {workflows, ratings} = input()

    ratings
    |> String.split("\n")
    |> Enum.reduce(0, fn r, acc ->
      acc + run(workflows, parse_rating(r), "in")
    end)
  end

  def part2() do
    {workflows, _} = input()

    dfs(workflows["in"], workflows)
    |> Enum.map(fn range ->
      range
      |> Map.values()
      |> Enum.map(fn {lo, hi} -> hi - lo + 1 end)
      |> Enum.product()
    end)
    |> Enum.sum()
  end

  def dfs([r | rs], workflows) do
    case r do
      "R" ->
        []

      "A" ->
        ["x", "m", "a", "s"]
        |> Enum.map(fn k -> {k, {1, 4000}} end)
        |> Map.new()
        |> then(fn range -> [range] end)

      {op, rating, val, next_part} ->
        when_true = dfs([next_part], workflows)
        when_false = dfs(rs, workflows)
        gt? = op == ">"

        # Need to deal with equal situations
        # when the result of op is false
        # To make it easier to handle in filter_ranges,
        # adjust `val` in advance here
        complement_val = val + if gt?, do: 1, else: -1

        filter_ranges(rating, gt?, val, when_true) ++
          filter_ranges(rating, not gt?, complement_val, when_false)

      part ->
        dfs(workflows[part], workflows)
    end
  end

  def filter_ranges(rating, gt?, val, ranges) do
    ranges
    |> Enum.map(fn range ->
      Map.update!(range, rating, fn {lo, hi} ->
        if gt?, do: {max(lo, val + 1), hi}, else: {lo, min(hi, val - 1)}
      end)
    end)
    |> Enum.filter(fn range ->
      not Enum.any?(range, fn {_, {lo, hi}} -> lo > hi end)
    end)
  end

  def run(workflows, ratings, part) do
    workflows[part]
    |> Enum.find(fn rule ->
      case rule do
        {">", rating, val, _} ->
          ratings[rating] > val

        {"<", rating, val, _} ->
          ratings[rating] < val

        _ ->
          true
      end
    end)
    |> then(fn part ->
      case check(part) do
        "A" ->
          Map.values(ratings) |> Enum.sum()

        "R" ->
          0

        next_part ->
          run(workflows, ratings, next_part)
      end
    end)
  end

  def check(part) do
    case part do
      {_, _, _, next_part} -> check(next_part)
      _ -> part
    end
  end

  def input() do
    [workflows, ratings] =
      File.read!("./input.txt")
      |> String.trim()
      |> String.split("\n\n")

    workflows =
      workflows
      |> String.split("\n")
      |> Enum.map(&parse_workflow/1)
      |> Map.new()

    {workflows, ratings}
  end

  def parse_workflow(s) do
    [name, rules | _] = String.split(s, ["{", "}"])

    rules =
      rules
      |> String.split(",")
      |> Enum.map(&parse_rule/1)

    {name, rules}
  end

  def parse_rule(r) do
    case String.split(r, ":") do
      [condition, name] ->
        cap = Regex.named_captures(~r/(?<rating>[xmas])(?<op>[<>])(?<val>\d+)/, condition)
        rating = cap["rating"]
        val = String.to_integer(cap["val"])
        {cap["op"], rating, val, name}

      [name] ->
        name
    end
  end

  def parse_rating(rating) do
    rating
    |> String.replace(["{", "}"], "")
    |> String.split(",")
    |> Enum.reduce(%{}, fn pair, acc ->
      [part, val] = String.split(pair, "=")
      Map.put(acc, part, String.to_integer(val))
    end)
  end
end
