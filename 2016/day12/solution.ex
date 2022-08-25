defmodule Solution do
  def part1() do
    aux()
  end

  def part2() do
    aux(1)
  end

  def aux(c \\ 0) do
    input()
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {cmd, i}, acc ->
      Map.put(acc, i, cmd)
    end)
    |> run(0, %{"a" => 0, "b" => 0, "c" => c, "d" => 0})
    |> Map.get("a")
  end

  def run(cmd, i, registers) do
    if cmd[i] == nil do
      registers
    else
      case cmd[i] do
        ["cpy", x, y] ->
          if Regex.match?(~r/[a-d]/, x) do
            {i + 1, Map.put(registers, y, registers[x])}
          else
            {i + 1, Map.put(registers, y, String.to_integer(x))}
          end

        ["inc", x] ->
          {i + 1, Map.update!(registers, x, &(&1 + 1))}

        ["dec", x] ->
          {i + 1, Map.update!(registers, x, &(&1 - 1))}

        ["jnz", x, y] ->
          if registers[x] == 0 do
            {i + 1, registers}
          else
            {i + String.to_integer(y), registers}
          end
      end
      |> then(fn {i, registers} -> run(cmd, i, registers) end)
    end
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.split/1)
    |> Enum.to_list()
  end
end
