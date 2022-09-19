defmodule Solution do
  def part1() do
    input()
    |> run(fn x -> elem(x, 1) end)
  end

  def part2() do
    input()
    |> run(&Function.identity/1)
  end

  def run(components, max_fn) do
    bfs(:queue.from_list([{0, 0, 0, components}]), [])
    |> Enum.max_by(max_fn)
    |> elem(1)
  end

  def bfs(q, bridges) do
    if :queue.is_empty(q) do
      bridges
    else
      {port, len, score, components} = :queue.head(q)
      q = :queue.tail(q)

      lst =
        components
        |> Enum.flat_map(fn [a, b] = component ->
          cond do
            a == port -> [{b, component}]
            b == port -> [{a, component}]
            true -> []
          end
        end)

      if lst == [] do
        bfs(q, [{len, score} | bridges])
      else
        score = score + port

        q =
          lst
          |> Enum.reduce(q, fn {p, component}, q ->
            :queue.in({p, len + 1, score + p, MapSet.delete(components, component)}, q)
          end)

        bfs(q, bridges)
      end
    end
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(fn s ->
      s
      |> String.split("/")
      |> Enum.map(&String.to_integer/1)
    end)
    |> Enum.to_list()
    |> MapSet.new()
  end
end
