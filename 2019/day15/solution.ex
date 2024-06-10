defmodule Solution do
  defmodule Program do
    defstruct [:mp, :i, :offset, :arg, :halted]

    def new(ins, i \\ 0, offset \\ 0, arg \\ 0) do
      %Program{mp: ins, i: i, offset: offset, arg: arg, halted: false}
    end

    def update_arg(p, arg) do
      %{p | arg: arg}
    end

    def run(%Program{halted: true} = p), do: {:halt, p}

    def run(%Program{mp: mp, i: i, offset: offset, arg: arg} = p) do
      s = "#{mp[i]}" |> String.pad_leading(5, "0")
      [a, b, c, d, e] = s |> String.graphemes() |> Enum.map(&String.to_integer/1)
      op = d * 10 + e

      args = [mp[i + 1] || 0, mp[i + 2] || 0, mp[i + 3] || 0]
      modes = [c, b, a]

      {reads, writes} =
        Enum.zip(args, modes)
        |> Enum.with_index()
        |> Enum.reduce({%{}, %{}}, fn {{arg, mode}, i}, {reads, writes} ->
          {
            Map.put(reads, i, elem({mp[arg] || 0, arg, mp[arg + offset] || 0}, mode)),
            Map.put(writes, i, elem({arg, nil, arg + offset}, mode))
          }
        end)

      case op do
        1 ->
          %{p | mp: Map.put(mp, writes[2], reads[0] + reads[1]), i: i + 4}

        2 ->
          %{p | mp: Map.put(mp, writes[2], reads[0] * reads[1]), i: i + 4}

        3 ->
          %{p | mp: Map.put(mp, writes[0], arg), i: i + 2}

        4 ->
          {:output, reads[0], %{p | i: i + 2}}

        5 ->
          i = if reads[0] != 0, do: reads[1], else: i + 3
          %{p | i: i}

        6 ->
          i = if reads[0] == 0, do: reads[1], else: i + 3
          %{p | i: i}

        7 ->
          v = if reads[0] < reads[1], do: 1, else: 0
          %{p | mp: Map.put(mp, writes[2], v), i: i + 4}

        8 ->
          v = if reads[0] == reads[1], do: 1, else: 0
          %{p | mp: Map.put(mp, writes[2], v), i: i + 4}

        9 ->
          %{p | i: i + 2, offset: offset + reads[0]}

        99 ->
          %{p | halted: true}
      end
      |> case do
        {:output, v, p} -> {:output, v, p}
        p -> run(p)
      end
    end
  end

  def part1() do
    mp = build_map()

    :queue.in({0, {0, 0}}, :queue.new())
    |> bfs(mp, "O")
  end

  def part2() do
    mp = build_map()
    {oxygen, _} = mp |> Enum.find(fn {_, v} -> v == "O" end)

    :queue.in({0, oxygen}, :queue.new())
    |> bfs(mp, "X")
  end

  def build_map() do
    prog = Program.new(input())
    start = {0, 0}
    build_map(%{start => "."}, start, prog)
  end

  def build_map(mp, curr, prog) do
    1..4
    |> Enum.reduce(mp, fn cmd, mp ->
      next = move(curr, cmd)

      if mp[next] != nil do
        mp
      else
        prog = Program.update_arg(prog, cmd)

        case Program.run(prog) do
          {:output, v, prog} ->
            case v do
              0 -> Map.put(mp, next, "#")
              1 -> Map.put(mp, next, ".") |> build_map(next, prog)
              2 -> Map.put(mp, next, "O") |> build_map(next, prog)
            end

          {:halt, _} ->
            mp
        end
      end
    end)
  end

  def bfs(q, mp, target, seen \\ %MapSet{}, steps \\ 0) do
    if :queue.is_empty(q) do
      steps
    else
      {{:value, {ct, {x, y} = pos}}, q} = :queue.out(q)

      cond do
        mp[pos] == target ->
          ct

        mp[pos] == "#" or pos in seen ->
          bfs(q, mp, target, seen, steps)

        true ->
          seen = MapSet.put(seen, pos)
          steps = max(ct, steps)

          [{-1, 0}, {0, 1}, {1, 0}, {0, -1}]
          |> Enum.reduce(q, fn {dx, dy}, q ->
            :queue.in({ct + 1, {x + dx, y + dy}}, q)
          end)
          |> bfs(mp, target, seen, steps)
      end
    end
  end

  def move({x, y}, cmd) do
    case cmd do
      1 -> {x - 1, y}
      2 -> {x + 1, y}
      3 -> {x, y - 1}
      4 -> {x, y + 1}
    end
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Enum.to_list()
    |> hd()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {n, i}, acc ->
      Map.put(acc, i, n)
    end)
  end
end
