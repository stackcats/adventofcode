defmodule Solution do
  def part1() do
    input()
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {cmd, i}, acc -> Map.put(acc, i, cmd) end)
    |> aux()
  end

  def aux(cmd, a \\ 0) do
    case run(cmd, 0, %{"a" => a, "b" => 0, "c" => 0, "d" => 0}, []) do
      true -> a
      _ -> aux(cmd, a + 1)
    end
  end

  def run(cmd, i, registers, output) do
    if length(output) == 8 do
      output == [1, 0, 1, 0, 1, 0, 1, 0]
    else
      case cmd[i] do
        ["cpy", x, y] ->
          cond do
            Regex.match?(~r/[a-d]/, x) ->
              run(cmd, i + 1, Map.put(registers, y, registers[x]), output)

            true ->
              run(cmd, i + 1, Map.put(registers, y, String.to_integer(x)), output)
          end

        ["inc", x] ->
          run(cmd, i + 1, Map.update!(registers, x, &(&1 + 1)), output)

        ["dec", x] ->
          run(cmd, i + 1, Map.update!(registers, x, &(&1 - 1)), output)

        ["jnz", x, y] ->
          x = if Regex.match?(~r/[-]?\d+/, x), do: String.to_integer(x), else: registers[x]
          y = if Regex.match?(~r/[-]?\d+/, y), do: String.to_integer(y), else: registers[y]

          if x == 0 do
            run(cmd, i + 1, registers, output)
          else
            run(cmd, i + y, registers, output)
          end

        ["out", x] ->
          run(cmd, i + 1, registers, [registers[x] | output])
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
