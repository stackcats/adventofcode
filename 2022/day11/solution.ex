defmodule Solution do
  defmodule Monkey do
    defstruct [:items, :op, :divisor, :t, :f, :ct]

    def new(items, op, divisor, t, f) do
      %Monkey{items: items, op: op, divisor: divisor, t: t, f: f, ct: 0}
    end
  end

  def part1() do
    input()
    |> round(20, &div(&1, 3))
  end

  def part2() do
    monkeys = input()

    common_divisor = monkeys |> Enum.reduce(1, fn {_id, monkey}, acc -> acc * monkey.divisor end)

    round(monkeys, 10000, &rem(&1, common_divisor))
  end

  def round(monkeys, 0, _reduce_fn) do
    monkeys
    |> Enum.sort_by(fn {_id, monkey} -> -monkey.ct end)
    |> Enum.take(2)
    |> Enum.map(fn {_id, monkey} -> monkey.ct end)
    |> Enum.product()
  end

  def round(monkeys, n, reduce_fn) do
    for i <- 0..(map_size(monkeys) - 1), reduce: monkeys do
      acc ->
        monkey = acc[i]

        monkey.items
        |> Enum.reduce(acc, fn item, acc ->
          item = monkey.op.(item) |> reduce_fn.()
          target = if rem(item, monkey.divisor) == 0, do: monkey.t, else: monkey.f

          Map.update!(acc, target, fn target_monkey ->
            %{target_monkey | items: [item | target_monkey.items]}
          end)
        end)
        |> Map.update!(i, fn monkey ->
          %{monkey | items: [], ct: monkey.ct + length(monkey.items)}
        end)
    end
    |> round(n - 1, reduce_fn)
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Enum.chunk_every(7, 7)
    |> Enum.reduce(%{}, fn lst, monkeys ->
      [id, items, op, divisor, t, f] =
        lst
        |> Enum.take(6)
        |> Enum.with_index()
        |> Enum.map(fn {s, i} ->
          case i do
            1 ->
              s
              |> String.replace(~r/[^0-9,]/, "")
              |> String.split(",")
              |> Enum.map(&String.to_integer/1)

            2 ->
              s
              |> String.replace("Operation: new = old ", "")

            _ ->
              s
              |> String.replace(~r/[^0-9,]/, "")
              |> String.to_integer()
          end
        end)

      monkey = Monkey.new(items, gen_op(op), divisor, t, f)
      Map.put(monkeys, id, monkey)
    end)
  end

  def gen_op(s) do
    [op, n] = s |> String.split(" ")

    fn a ->
      b = if n == "old", do: a, else: String.to_integer(n)

      case op do
        "*" -> a * b
        "+" -> a + b
      end
    end
  end
end
