defmodule Solution do
  def part1() do
    run() |> Enum.count(&Kernel.>(&1, 0))
  end

  def part2() do
    run() |> Enum.sum()
  end

  def run() do
    {patterns, designs} = input()

    Agent.start_link(fn -> %{} end, name: __MODULE__)
    Agent.update(__MODULE__, fn _ -> %{} end)

    designs
    |> Enum.map(fn s -> count(s, patterns) end)
  end

  def count("", _patterns), do: 1

  def count(s, patterns) do
    case Agent.get(__MODULE__, fn m -> m[s] end) do
      nil ->
        len = String.length(s)

        patterns
        |> Enum.reduce(0, fn p, acc ->
          acc +
            if String.starts_with?(s, p) do
              s
              |> String.slice(String.length(p)..len)
              |> count(patterns)
            else
              0
            end
        end)
        |> tap(fn ct -> Agent.update(__MODULE__, &Map.put(&1, s, ct)) end)

      ct ->
        ct
    end
  end

  def input() do
    [patterns, designs] = File.read!("./input.txt") |> String.split("\n\n", trim: true)
    {String.split(patterns, ", "), String.split(designs, "\n", trim: true)}
  end
end
