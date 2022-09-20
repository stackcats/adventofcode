defmodule Solution do
  @steps 12_794_428

  def part1() do
    states = input()

    for i <- 1..@steps, reduce: {%{0 => 0}, 0, "A"} do
      {tape, pos, state} ->
        {v, d, next_state} = states[state][tape[pos] || 0]
        {Map.put(tape, pos, v), pos + d, next_state}
    end
    |> elem(0)
    |> Map.values()
    |> Enum.count(&(&1 == 1))
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.filter(&(&1 != ""))
    |> Stream.chunk_every(9)
    |> Stream.map(&Enum.join/1)
    |> Stream.map(fn s ->
      ~r/In state (?<state>[A-Z]):If the current value is 0:- Write the value (?<value0>\d).- Move one slot to the (?<dir0>(right|left)).- Continue with state (?<target0>[A-Z]).If the current value is 1:- Write the value (?<value1>\d).- Move one slot to the (?<dir1>(right|left)).- Continue with state (?<target1>[A-Z])./
      |> Regex.named_captures(s)
      |> then(fn m ->
        f = fn
          "left" -> -1
          "right" -> 1
        end

        {m["state"],
         %{
           0 => {String.to_integer(m["value0"]), f.(m["dir0"]), m["target0"]},
           1 => {String.to_integer(m["value1"]), f.(m["dir1"]), m["target1"]}
         }}
      end)
    end)
    |> Enum.reduce(%{}, fn {k, v}, acc ->
      Map.put(acc, k, v)
    end)
  end
end
