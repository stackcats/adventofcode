defmodule Solution do
  defmodule Program do
    defstruct [:mp, :i, :offset, :arg, :halted]

    def new(ins, i, offset, arg) do
      %Program{mp: ins, i: i, offset: offset, arg: arg, halted: false}
    end

    def update_arg(p, arg) do
      %{p | arg: arg}
    end

    def run(%Program{halted: true} = p), do: {:halted, p}

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
        {:output, v, p} ->
          {:output, v, p}

        p ->
          run(p)
      end
    end
  end

  def part1() do
    p = Program.new(input(), 0, 0, 0)

    doit(%{}, {0, 0}, {-1, 0}, p)
    |> map_size()
  end

  def part2() do
    p = Program.new(input(), 0, 0, 0)

    doit(%{{0, 0} => 1}, {0, 0}, {-1, 0}, p)
    |> print()
    |> IO.puts()
  end

  def doit(g, _, _, %Program{halted: true}), do: g

  def doit(g, curr, dir, p) do
    p = Program.update_arg(p, g[curr] || 0)
    {g, p} = paint(g, curr, p)
    {curr, dir, p} = move(curr, dir, p)
    doit(g, curr, dir, p)
  end

  def print(g) do
    {{x1, y1}, {x2, y2}} = g |> Map.keys() |> Enum.min_max()

    for i <- x1..x2 do
      for j <- y1..y2 do
        case g[{i, j}] do
          1 -> "#"
          _ -> "."
        end
      end
      |> Enum.join("")
    end
    |> Enum.join("\n")
  end

  def paint(g, curr, p) do
    case Program.run(p) do
      {:halted, p} -> {g, p}
      {:output, v, p} -> {Map.put(g, curr, v), p}
    end
  end

  def move({x, y} = curr, dir, p) do
    case Program.run(p) do
      {:halted, p} ->
        {curr, dir, p}

      {:output, 0, p} ->
        {dx, dy} = dir = turn(dir, -1)
        {{x + dx, y + dy}, dir, p}

      {:output, 1, p} ->
        {dx, dy} = dir = turn(dir, 1)
        {{x + dx, y + dy}, dir, p}
    end
  end

  def turn(dir, offset) do
    lst = [{-1, 0}, {0, 1}, {1, 0}, {0, -1}]
    i = Enum.find_index(lst, &(&1 == dir))
    i = rem(i + 4 + offset, 4)
    Enum.at(lst, i)
  end

  def run(mp, arg, i \\ 0, offset \\ 0) do
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
          Map.put(reads, i, elem({mp[arg], arg, mp[arg + offset]}, mode)),
          Map.put(writes, i, elem({arg, nil, arg + offset}, mode))
        }
      end)

    case op do
      1 ->
        mp |> Map.put(writes[2], reads[0] + reads[1]) |> run(arg, i + 4, offset)

      2 ->
        mp |> Map.put(writes[2], reads[0] * reads[1]) |> run(arg, i + 4, offset)

      3 ->
        mp |> Map.put(writes[0], arg) |> run(arg, i + 2, offset)

      4 ->
        {reads[0], mp, i, offset}

      5 ->
        i = if reads[0] != 0, do: reads[1], else: i + 3
        run(mp, arg, i, offset)

      6 ->
        i = if reads[0] == 0, do: reads[1], else: i + 3
        run(mp, arg, i, offset)

      7 ->
        v = if reads[0] < reads[1], do: 1, else: 0
        mp |> Map.put(writes[2], v) |> run(arg, i + 4, offset)

      8 ->
        v = if reads[0] == reads[1], do: 1, else: 0
        mp |> Map.put(writes[2], v) |> run(arg, i + 4, offset)

      9 ->
        run(mp, arg, i + 2, offset + reads[0])

      99 ->
        :done
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
