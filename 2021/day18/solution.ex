defmodule Solution do
  def part1() do
    input()
    |> Enum.reduce(fn x, acc -> reduce([acc, x]) end)
    |> magnitude()
  end

  def part2() do
    lst = input() |> Enum.with_index()

    for {a, i} <- lst, {b, j} <- lst, i != j do
      magnitude(reduce([a, b]))
    end
    |> Enum.max()
  end

  defp magnitude([a, b]) do
    a = if is_list(a), do: magnitude(a), else: a
    b = if is_list(b), do: magnitude(b), else: b
    3 * a + 2 * b
  end

  defp reduce(n) do
    case explode(n) do
      {true, n, _, _} ->
        reduce(n)

      {false, n, _, _} ->
        case split(n) do
          {true, n} -> reduce(n)
          {false, n} -> n
        end
    end
  end

  defp split(n) when is_number(n) do
    if n < 10 do
      {false, n}
    else
      a = div(n, 2)
      {true, [a, n - a]}
    end
  end

  defp split([a, b]) do
    case split(a) do
      {true, a} ->
        {true, [a, b]}

      {false, _} ->
        {r, b} = split(b)
        {r, [a, b]}
    end
  end

  defp explode(n) do
    explode(n, 0)
  end

  defp explode(n, _) when is_number(n) do
    {false, n, nil, nil}
  end

  defp explode([a, b], depth) when depth >= 4 do
    {true, 0, a, b}
  end

  defp explode([a, b], depth) do
    {is_exploded, a, left, right} = explode(a, depth + 1)

    if is_exploded == false do
      {is_exploded, b, left, right} = explode(b, depth + 1)
      {is_exploded, [explode_to_left(left, a), b], nil, right}
    else
      {true, [a, explode_to_right(right, b)], left, nil}
    end
  end

  defp explode_to_right(nil, n), do: n

  defp explode_to_right(to_added, n) when is_number(n), do: to_added + n

  defp explode_to_right(to_added, [a, b]) do
    [explode_to_right(to_added, a), b]
  end

  defp explode_to_left(nil, n), do: n

  defp explode_to_left(to_added, n) when is_number(n), do: to_added + n

  defp explode_to_left(to_added, [a, b]) do
    [a, explode_to_left(to_added, b)]
  end

  defp input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&Code.eval_string/1)
    |> Stream.map(fn tp -> elem(tp, 0) end)
    |> Enum.to_list()
  end
end
