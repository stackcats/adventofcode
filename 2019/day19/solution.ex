defmodule Solution do
  defmodule Program do
    defstruct [:mp, :i, :offset, :arg, :halted]

    def new(ins, arg \\ [], i \\ 0, offset \\ 0) do
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
          [x | xs] = arg
          %{p | mp: Map.put(mp, writes[0], x), i: i + 2, arg: xs}

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
    ins = input()

    for y <- 0..49, x <- 0..49, reduce: 0 do
      ct -> ct + beam(ins, y, x)
    end
  end

  def part2() do
    input() |> find_square(0, 0)
  end

  def find_square(ins, y, x) do
    cond do
      beam(ins, y + 99, x) == 0 -> find_square(ins, y, x + 1)
      beam(ins, y, x + 99) == 1 -> y + x * 10000
      true -> find_square(ins, y + 1, x)
    end
  end

  def beam(ins, y, x) do
    Program.new(ins, [x, y])
    |> Program.run()
    |> elem(1)
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
