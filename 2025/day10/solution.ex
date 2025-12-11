defmodule Solution do
  import Bitwise

  def part1() do
    input()
    |> Enum.map(fn {pattern, ops, _} ->
      len = length(pattern)

      target =
        pattern
        |> Enum.join()
        |> String.to_integer(2)

      ops =
        ops
        |> Enum.map(fn op ->
          Enum.reduce(op, 0, fn n, acc ->
            acc ||| 1 <<< (len - n - 1)
          end)
        end)

      ops
      |> Enum.map(fn op -> {op, 1} end)
      |> :queue.from_list()
      |> bfs(%MapSet{}, ops, target)
    end)
    |> Enum.sum()
  end

  def part2() do
    input()
    |> Enum.map(fn {_, buttons, jolt} ->
      smt = build_smt(buttons, jolt)

      file = "z3_input.smt2"

      File.write!(file, smt)

      {output, 0} = System.cmd("z3", [file])

      File.rm(file)

      [_, n] = Regex.run(~r/total (\d+)/, output)
      String.to_integer(n)
    end)
    |> Enum.sum()
  end

  def build_smt(buttons, jolt) do
    smt = "(reset)"
    n = length(buttons) - 1

    smt =
      for i <- 0..n, reduce: smt do
        acc -> append(acc, "(declare-const x#{i} Int)\n(assert (>= x#{i} 0))")
      end

    smt =
      Enum.with_index(jolt)
      |> Enum.reduce(smt, fn {v, i}, acc ->
        buttons
        |> Enum.with_index()
        |> Enum.filter(fn {button, _} -> i in button end)
        |> Enum.map(fn {_, j} -> "x#{j}" end)
        |> Enum.join(" ")
        |> then(fn vars ->
          append(acc, "(assert (= (+ #{vars}) #{v}))")
        end)
      end)

    smt = append(smt, "(declare-const total Int)")

    vars = Enum.map(0..n, &"x#{&1}") |> Enum.join(" ")

    smt
    |> append("(assert (= total (+ #{vars})))")
    |> append("(minimize total)")
    |> append("(check-sat)")
    |> append("(get-objectives)")
  end

  def append(s, t), do: "#{s}\n#{t}"

  def bfs(q, memo, ops, target) do
    case :queue.out(q) do
      {:empty, _} ->
        raise "empty queue"

      {{_, {n, ct}}, q} ->
        cond do
          n == target ->
            ct

          n in memo ->
            bfs(q, memo, ops, target)

          true ->
            memo = MapSet.put(memo, n)

            ops
            |> Enum.reduce(q, fn m, q -> :queue.in({bxor(n, m), ct + 1}, q) end)
            |> bfs(memo, ops, target)
        end
    end
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(fn s ->
      [indicator | rst] =
        s
        |> String.trim()
        |> String.split(" ")

      jolt_req = List.last(rst)

      buttons = rst |> Enum.reverse() |> tl() |> Enum.reverse()

      pattern =
        String.slice(indicator, 1..-2//1)
        |> String.graphemes()
        |> Enum.map(fn
          "#" -> "1"
          "." -> "0"
        end)

      buttons =
        buttons
        |> Enum.map(fn s ->
          s
          |> String.slice(1..-2//1)
          |> String.split(",")
          |> Enum.map(&String.to_integer/1)
        end)

      {pattern, buttons, to_list(jolt_req)}
    end)
  end

  def to_list(s) do
    s
    |> String.slice(1..-2//1)
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end
end
