defmodule Solution do
  defmodule Program do
    defstruct [:mp, :i, :offset, :arg, :output, :status]

    def new(ins, arg \\ [], i \\ 0, offset \\ 0) do
      %Program{mp: ins, i: i, offset: offset, arg: arg, output: [], status: :ready}
    end

    def update_arg(p, f) do
      %{p | arg: f.(p.arg), status: :ready}
    end

    def out(p) do
      {p.output, %{p | output: []}}
    end

    def run(%Program{status: status} = p) when status in [:waiting, :halted], do: p

    def run(%Program{mp: mp, i: i, offset: offset, arg: arg, output: output} = p) do
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
          case arg do
            [] -> %{p | status: :waiting}
            [x | xs] -> %{p | mp: Map.put(mp, writes[0], x), i: i + 2, arg: xs}
          end

        4 ->
          %{p | i: i + 2, output: output ++ [reads[0]]}

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
          %{p | status: :halted}
      end
      |> run()
    end
  end

  def part1() do
    init()
    |> Stream.iterate(&run/1)
    |> Stream.map(& &1.y)
    |> Stream.reject(&is_nil/1)
    |> Enum.at(0)
  end

  def part2() do
    init()
    |> Stream.iterate(&run/1)
    |> Stream.map(& &1.y)
    |> Stream.reject(&is_nil/1)
    |> Stream.transform(%MapSet{}, fn y, acc ->
      if y in acc, do: {:halt, y}, else: {[y], MapSet.put(acc, y)}
    end)
    |> Enum.to_list()
    |> List.last()
  end

  def init() do
    %{computers: gen_computers(), curr: 0, nat: nil, y: nil}
  end

  def gen_computers() do
    0..49
    |> Map.new(fn addr -> {addr, Program.new(input(), [addr]) |> Program.run()} end)
  end

  def run(state) do
    if state.nat != nil and Enum.all?(state.computers, fn {_, p} -> p.arg == [] end) do
      [_, x, y] = state.nat

      computers =
        state.computers
        |> Map.update!(0, fn prog ->
          Program.update_arg(prog, fn _ -> [x, y] end)
        end)

      %{state | computers: computers, curr: 0, nat: nil, y: y}
    else
      prog = state.computers[state.curr]

      {output, prog} =
        if prog.arg == [] do
          Program.update_arg(prog, fn _ -> [-1] end)
        else
          prog
        end
        |> Program.run()
        |> Program.out()

      computers = Map.put(state.computers, state.curr, prog)

      {nat, output} =
        output
        |> Enum.chunk_every(3)
        |> Enum.split_with(&match?([255, _, _], &1))

      curr = rem(state.curr + 1, map_size(computers))

      computers =
        output
        |> Enum.reduce(computers, fn [addr, x, y], acc ->
          Map.update!(acc, addr, fn prog ->
            Program.update_arg(prog, fn arg -> arg ++ [x, y] end)
          end)
        end)

      %{state | computers: computers, curr: curr, nat: List.last(nat), y: nil}
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
