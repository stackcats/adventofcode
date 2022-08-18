defmodule Solution do
  def part1() do
    input()
    |> eval(0, %{"a" => 0, "b" => 0})
    |> Map.get("b")
  end

  def part2() do
    input()
    |> eval(0, %{"a" => 1, "b" => 0})
    |> Map.get("b")
  end

  def eval(ins, i, rs) do
    if not Map.has_key?(ins, i) do
      rs
    else
      {i, rs} =
        case ins[i] do
          ["hlf", r] ->
            {i + 1, Map.update!(rs, r, &div(&1, 2))}

          ["tpl", r] ->
            {i + 1, Map.update!(rs, r, &(&1 * 3))}

          ["inc", r] ->
            {i + 1, Map.update!(rs, r, &(&1 + 1))}

          ["jmp", offset] ->
            {i + String.to_integer(offset), rs}

          ["jie", r, offset] ->
            if rem(rs[r], 2) == 0 do
              {i + String.to_integer(offset), rs}
            else
              {i + 1, rs}
            end

          ["jio", r, offset] ->
            if rs[r] == 1 do
              {i + String.to_integer(offset), rs}
            else
              {i + 1, rs}
            end
        end

      eval(ins, i, rs)
    end
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.replace(&1, ",", ""))
    |> Stream.map(&String.split/1)
    |> Enum.to_list()
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {ins, i}, acc ->
      Map.put(acc, i, ins)
    end)
  end
end
