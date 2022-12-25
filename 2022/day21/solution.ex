defmodule Solution do
  def part1() do
    mp = input()
    eval(mp, "root")
  end

  def part2() do
    mp = input()
    {_, a, b} = mp["root"]
    mp = Map.delete(mp, "humn")

    case {eval(mp, a), eval(mp, b)} do
      {nil, n} -> find(mp, a, n)
      {n, nil} -> find(mp, b, n)
    end
  end

  def find(_mp, "humn", val), do: val

  def find(mp, name, val) do
    {op, a, b} = mp[name]

    case {eval(mp, a), eval(mp, b)} do
      {nil, n} ->
        case op do
          "+" -> find(mp, a, val - n)
          "-" -> find(mp, a, n + val)
          "*" -> find(mp, a, div(val, n))
          "/" -> find(mp, a, n * val)
        end

      {n, nil} ->
        case op do
          "+" -> find(mp, b, val - n)
          "-" -> find(mp, b, n - val)
          "*" -> find(mp, b, div(val, n))
          "/" -> find(mp, b, div(val, n))
        end
    end
  end

  def eval(mp, curr) do
    try do
      case mp[curr] do
        {"+", a, b} -> eval(mp, a) + eval(mp, b)
        {"-", a, b} -> eval(mp, a) - eval(mp, b)
        {"*", a, b} -> eval(mp, a) * eval(mp, b)
        {"/", a, b} -> div(eval(mp, a), eval(mp, b))
        n -> n
      end
    rescue
      ArithmeticError -> nil
    end
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Enum.reduce(%{}, fn s, acc ->
      if String.length(s) == 17 do
        ~r/([a-z]{4}): ([a-z]{4}) ([-+*\/]) ([a-z]{4})/
      else
        ~r/([a-z]{4}): (\d+)/
      end
      |> Regex.scan(s)
      |> then(fn [lst] ->
        case lst do
          [_, name, n] -> Map.put(acc, name, String.to_integer(n))
          [_, name, a, op, b] -> Map.put(acc, name, {op, a, b})
        end
      end)
    end)
  end
end
