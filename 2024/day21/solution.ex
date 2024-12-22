defmodule Solution do
  @num_pad %{
    "0" => [{"2", "^"}, {"A", ">"}],
    "1" => [{"2", ">"}, {"4", "^"}],
    "2" => [{"0", "v"}, {"1", "<"}, {"3", ">"}, {"5", "^"}],
    "3" => [{"2", "<"}, {"6", "^"}, {"A", "v"}],
    "4" => [{"1", "v"}, {"5", ">"}, {"7", "^"}],
    "5" => [{"2", "v"}, {"4", "<"}, {"6", ">"}, {"8", "^"}],
    "6" => [{"3", "v"}, {"5", "<"}, {"9", "^"}],
    "7" => [{"4", "v"}, {"8", ">"}],
    "8" => [{"5", "v"}, {"7", "<"}, {"9", ">"}],
    "9" => [{"6", "v"}, {"8", "<"}],
    "A" => [{"0", "<"}, {"3", "^"}]
  }

  @dir_pad %{
    "^" => [{"A", ">"}, {"v", "v"}],
    "<" => [{"v", ">"}],
    "v" => [{"<", "<"}, {"^", "^"}, {">", ">"}],
    ">" => [{"v", "<"}, {"A", "^"}],
    "A" => [{"^", "<"}, {">", "v"}]
  }

  @pads %{0 => @num_pad, 1 => @dir_pad}

  def part1() do
    run(3)
  end

  def part2() do
    run(26)
  end

  def run(robots) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
    Agent.update(__MODULE__, fn _ -> %{} end)

    input()
    |> Enum.reduce(0, fn code, acc ->
      {num, _} = Integer.parse(code)

      acc + num * dfs(code, robots, 0)
    end)
  end

  def dfs(code, robots, pad) do
    cache_key = {code, robots, pad}

    case Agent.get(__MODULE__, fn m -> m[cache_key] end) do
      nil ->
        String.graphemes("A" <> code)
        |> Enum.chunk_every(2, 1, :discard)
        |> Enum.reduce(0, fn [from, to], acc ->
          paths = bfs(from, to, @pads[pad])

          if robots == 1 do
            Enum.map(paths, &String.length/1)
          else
            Enum.map(paths, &dfs(&1, robots - 1, 1))
          end
          |> Enum.min()
          |> Kernel.+(acc)
        end)
        |> tap(fn sum -> Agent.update(__MODULE__, &Map.put(&1, cache_key, sum)) end)

      cache ->
        cache
    end
  end

  def bfs(from, to, g) do
    [{from, ""}]
    |> :queue.from_list()
    |> bfs(to, g, nil, [])
  end

  def bfs(q, to, g, shortest, paths) do
    case :queue.out(q) do
      {:empty, _} ->
        paths

      {{_, {curr, path}}, q} ->
        len = String.length(path)

        cond do
          shortest != nil and len > shortest ->
            bfs(q, to, g, shortest, paths)

          curr == to ->
            path = path <> "A"

            cond do
              shortest == nil or shortest > len -> bfs(q, to, g, len, [path])
              shortest == len -> bfs(q, to, g, len, [path | paths])
              true -> bfs(q, to, g, shortest, paths)
            end

          true ->
            g[curr]
            |> Enum.reduce(q, fn {next, p}, q -> :queue.in({next, path <> p}, q) end)
            |> bfs(to, g, shortest, paths)
        end
    end
  end

  def input() do
    File.read!("./input.txt") |> String.split("\n", trim: true)
  end
end
