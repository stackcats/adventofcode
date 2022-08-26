defmodule Solution do
  def part1() do
    {q, cmds} = input()

    run(q, cmds, %{}, %{})
    |> elem(0)
    |> Enum.find(fn {_, v} -> v == [17, 61] end)
    |> elem(0)
  end

  def part2() do
    {q, cmds} = input()

    run(q, cmds, %{}, %{})
    |> elem(1)
    |> then(fn m ->
      m[0] * m[1] * m[2]
    end)
  end

  def run(q, cmds, bots, outputs) do
    if :queue.is_empty(q) do
      {bots, outputs}
    else
      {v, bot} = :queue.head(q)
      q = :queue.drop(q)
      bots = Map.update(bots, bot, [v], &Enum.sort([v | &1]))

      case bots[bot] do
        [low, high] ->
          {low_target, low_n, high_target, high_n} = cmds[bot]

          [{low_target, low_n, low}, {high_target, high_n, high}]
          |> Enum.reduce({q, outputs}, fn {target, n, v}, {q, outputs} ->
            if target == "output" do
              {q, Map.put(outputs, n, v)}
            else
              {:queue.in({v, n}, q), outputs}
            end
          end)
          |> then(fn {q, outputs} ->
            run(q, cmds, bots, outputs)
          end)

        _ ->
          run(q, cmds, bots, outputs)
      end
    end
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Enum.to_list()
    |> Enum.reduce({:queue.new(), %{}}, fn s, {q, cmds} ->
      lst = String.split(s, " ")

      if hd(lst) == "value" do
        [_, v, _, _, _, bot] = lst

        {:queue.in({String.to_integer(v), String.to_integer(bot)}, q), cmds}
      else
        [_, bot, _, _, _, low_target, low_target_num, _, _, _, high_target, high_target_num] = lst

        cmd =
          {low_target, String.to_integer(low_target_num), high_target,
           String.to_integer(high_target_num)}

        {q, Map.put(cmds, String.to_integer(bot), cmd)}
      end
    end)
  end
end
