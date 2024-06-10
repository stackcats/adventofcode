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
    mp = build_map()

    mp
    |> Map.filter(fn {{x, y}, c} ->
      c == "#" and mp[{x - 1, y}] == "#" and mp[{x + 1, y}] == "#" and mp[{x, y + 1}] == "#" and
        mp[{x, y - 1}] == "#"
    end)
    |> Map.keys()
    |> Enum.map(fn {x, y} -> x * y end)
    |> Enum.sum()
  end

  def part2() do
    mp = build_map()
    {start, _} = mp |> Enum.find(fn {_, v} -> v == "^" end)

    path = get_path(mp, start, {-1, 0}, [])

    functions = find_functions(path)

    main =
      functions
      |> Enum.zip(?A..?Z)
      |> Enum.reduce(path, fn {s, f}, acc ->
        String.replace(acc, s, List.to_string([f]))
      end)

    args =
      [main, functions, "N\n"] |> List.flatten() |> Enum.join("\n") |> String.to_charlist()

    input()
    |> Map.put(0, 2)
    |> Program.new(args)
    |> run([])
    |> List.last()
  end

  def get_path(mp, curr, dir, path) do
    cond do
      mp[step(curr, turn_left(dir))] == "#" -> {"L", turn_left(dir)}
      mp[step(curr, turn_right(dir))] == "#" -> {"R", turn_right(dir)}
      true -> nil
    end
    |> case do
      nil ->
        Enum.reverse(path) |> Enum.join(",")

      {cmd, dir} ->
        ct = count_steps(mp, curr, dir) - 1
        curr = jump(curr, dir, ct)
        get_path(mp, curr, dir, ["#{ct}", cmd | path])
    end
  end

  def find_functions(s) do
    case find_part(s) do
      nil ->
        []

      t ->
        s = String.replace(s, t, "") |> String.trim(",")
        [t | find_functions(s)]
    end
  end

  def find_part(s) do
    s
    |> String.length()
    |> Range.new(0, -1)
    |> Enum.reduce_while(nil, fn i, acc ->
      if String.at(s, i) in ["R", "L", ","] or String.at(s, i + 1) != "," do
        {:cont, acc}
      else
        sub = String.slice(s, 0..i)

        sub
        |> Regex.compile!()
        |> Regex.scan(s)
        |> length()
        |> case do
          1 -> {:cont, acc}
          _ -> {:halt, sub}
        end
      end
    end)
  end

  def jump({x, y}, {dx, dy}, ct) do
    {x + dx * ct, y + dy * ct}
  end

  def count_steps(mp, curr, dir) do
    if mp[curr] not in ["#", "^"] do
      0
    else
      1 + count_steps(mp, step(curr, dir), dir)
    end
  end

  def step({x, y}, {dx, dy}), do: {x + dx, y + dy}

  def turn_left({dx, dy}), do: {-dy, dx}

  def turn_right({dx, dy}), do: {dy, -dx}

  def build_map() do
    input()
    |> Program.new()
    |> run([])
    |> List.to_string()
    |> String.split("\n")
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {r, i}, acc ->
      r
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {c, j}, acc -> Map.put(acc, {i, j}, c) end)
    end)
  end

  def run(prog, outputs) do
    case Program.run(prog) do
      {:output, v, prog} ->
        run(prog, [v | outputs])

      _ ->
        outputs |> Enum.reverse()
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
