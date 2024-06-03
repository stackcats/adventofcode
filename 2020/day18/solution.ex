defmodule Solution do
  def part1() do
    run(%{"+" => 1, "*" => 1, "(" => 10})
  end

  def part2() do
    run(%{"+" => 2, "*" => 1, "(" => 10})
  end

  def run(precedence) do
    input()
    |> Enum.map(&eval(&1, precedence))
    |> Enum.sum()
  end

  def eval(ins, precedence) do
    ins
    |> Enum.reduce({[], []}, fn
      n, {ops, st} when is_integer(n) -> {ops, [n | st]}
      ")", {ops, st} -> pop_parentheses(ops, st)
      op, {ops, st} -> pop_ops(ops, op, st, precedence)
    end)
    |> then(fn {ops, st} -> Enum.reverse(ops) ++ st end)
    |> Enum.reverse()
    |> Enum.reduce([], fn
      "+", [a, b | st] -> [a + b | st]
      "*", [a, b | st] -> [a * b | st]
      n, st -> [n | st]
    end)
    |> hd()
  end

  def pop_ops([], new_op, st, _), do: {[new_op], st}

  def pop_ops([op | ops], new_op, st, precedence) do
    if op == "(" or precedence[op] < precedence[new_op] do
      {[new_op, op | ops], st}
    else
      pop_ops(ops, new_op, [op | st], precedence)
    end
  end

  def pop_parentheses(["(" | ops], st), do: {ops, st}

  def pop_parentheses([op | ops], st), do: pop_parentheses(ops, [op | st])

  def input() do
    File.stream!("input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(fn s ->
      s
      |> String.replace(" ", "")
      |> String.graphemes()
      |> Enum.map(fn
        op when op in ["+", "(", ")", "*"] -> op
        n -> String.to_integer(n)
      end)
    end)
  end
end
