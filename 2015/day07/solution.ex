defmodule Solution do
  use Bitwise

  def part1() do
    input()
    |> parse(%{})
    |> eval(%{}, "a")
    |> elem(1)
  end

  def part2() do
    input()
    |> parse(%{})
    |> eval(%{"b" => 46065}, "a")
    |> elem(1)
  end

  def parse([], ops), do: ops

  def parse([x | xs], ops) do
    case x do
      [a, "->", c] -> {{&Function.identity/1, a}, c}
      [a, "AND", b, "->", c] -> {{&band/2, a, b}, c}
      [a, "OR", b, "->", c] -> {{&bor/2, a, b}, c}
      [a, "LSHIFT", b, "->", c] -> {{&bsl/2, a, b}, c}
      [a, "RSHIFT", b, "->", c] -> {{&bsr/2, a, b}, c}
      ["NOT", a, "->", c] -> {{&bnot/1, a}, c}
    end
    |> then(fn {op, c} ->
      parse(xs, Map.put(ops, c, op))
    end)
  end

  def eval(ops, ctx, k) do
    cond do
      Regex.match?(~r{\A\d*\z}, k) ->
        {ctx, String.to_integer(k)}

      Map.has_key?(ctx, k) ->
        {ctx, ctx[k]}

      true ->
        case ops[k] do
          {f, a} ->
            {ctx, v} = eval(ops, ctx, a)
            v = f.(v)
            {Map.put(ctx, k, v), v}

          {f, a, b} ->
            {ctx, v1} = eval(ops, ctx, a)
            {ctx, v2} = eval(ops, ctx, b)
            v = f.(v1, v2)
            {Map.put(ctx, k, v), v}
        end
    end
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.split/1)
    |> Enum.to_list()
  end
end
