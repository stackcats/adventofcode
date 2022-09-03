defmodule Solution do
  def part1() do
    aux(7)
  end

  def part2() do
    aux(12)
  end

  def aux(a \\ 0) do
    input()
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {cmd, i}, acc ->
      Map.put(acc, i, cmd)
    end)
    |> run(0, %{"a" => a, "b" => 0, "c" => 0, "d" => 0})
    |> Map.get("a")
  end

  def run(cmd, 5, registers) do
    run(cmd, 5 + 5, Map.update!(registers, "a", &(&1 + registers["c"] * registers["d"])))
  end

  def run(cmd, 21, registers) do
    run(cmd, 21 + 5, Map.update!(registers, "a", &(&1 + registers["c"] * registers["d"])))
  end

  def run(cmd, i, registers) do
    if cmd[i] == nil do
      registers
    else
      case cmd[i] do
        ["cpy", x, y] ->
          cond do
            Regex.match?(~r/[-]?\d+/, y) -> run(cmd, i + 1, registers)
            Regex.match?(~r/[a-d]/, x) -> run(cmd, i + 1, Map.put(registers, y, registers[x]))
            true -> run(cmd, i + 1, Map.put(registers, y, String.to_integer(x)))
          end

        ["inc", x] ->
          run(cmd, i + 1, Map.update!(registers, x, &(&1 + 1)))

        ["dec", x] ->
          run(cmd, i + 1, Map.update!(registers, x, &(&1 - 1)))

        ["jnz", x, y] ->
          x = if Regex.match?(~r/[-]?\d+/, x), do: String.to_integer(x), else: registers[x]
          y = if Regex.match?(~r/[-]?\d+/, y), do: String.to_integer(y), else: registers[y]

          if x == 0 do
            run(cmd, i + 1, registers)
          else
            run(cmd, i + y, registers)
          end

        ["tgl", x] ->
          cmd
          |> toggle(i + registers[x])
          |> run(i + 1, registers)
      end
    end
  end

  def toggle(cmd, i) do
    case cmd[i] do
      ["inc", x] -> ["dec", x]
      ["dec", x] -> ["inc", x]
      ["tgl", x] -> ["inc", x]
      ["jnz", x, y] -> ["cpy", x, y]
      ["cpy", x, y] -> ["jnz", x, y]
      _ -> nil
    end
    |> then(&Map.put(cmd, i, &1))
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.split/1)
    |> Enum.to_list()
  end
end
