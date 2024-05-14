defmodule Solution do
  def part1() do
    modules = input()

    1..1000
    |> Enum.reduce({modules, {0, 0}}, fn _, {modules, counts} ->
      q = :queue.new()
      q = :queue.snoc(q, {"button", "broadcaster", false})
      bfs(q, modules, counts)
    end)
    |> then(fn {_, {lo, hi}} -> lo * hi end)
  end

  def part2() do
    # After checking the puzzle input
    # we find that there is only one conjunction module in the input of rx
    # and all the inputs of this module are conjunction modules
    # according to the rule
    # we only need to find the time when these conjunction modules are input low at the same time.
    modules = input()
    {_, _, [m]} = modules["rx"]
    {_, _, inputs} = modules[m]

    inputs
    |> Map.keys()
    |> Enum.map(fn target ->
      q = :queue.new()
      q = :queue.snoc(q, {"button", "broadcaster", false})
      bfs2(q, modules, target, 1)
    end)
    |> Enum.reduce(&lcm/2)
  end

  def lcm(a, b) do
    g = Integer.gcd(a, b)
    div(a * b, g)
  end

  def bfs(q, modules, counts) do
    case :queue.out(q) do
      {:empty, _} ->
        {modules, counts}

      {{_, {from, curr, pulse}}, q} ->
        counts = update_count(counts, pulse)

        module = modules[curr]
        outputs = elem(module, 1)

        {pulse, module} =
          case module do
            {:ff, outputs, state} ->
              if pulse do
                {nil, module}
              else
                state = not state
                {state, {:ff, outputs, state}}
              end

            {:conj, outputs, inputs} ->
              inputs = Map.put(inputs, from, pulse)
              pulse = not Enum.all?(inputs, fn {_, v} -> v end)
              {pulse, {:conj, outputs, inputs}}

            _ ->
              {false, module}
          end

        modules = Map.put(modules, curr, module)

        if pulse == nil do
          bfs(q, modules, counts)
        else
          outputs
          |> Enum.reduce(q, fn to, q ->
            :queue.snoc(q, {curr, to, pulse})
          end)
          |> bfs(modules, counts)
        end
    end
  end

  def bfs2(q, modules, target, n) do
    case :queue.out(q) do
      {:empty, _} ->
        q = :queue.new()
        q = :queue.snoc(q, {"button", "broadcaster", false})
        bfs2(q, modules, target, n + 1)

      {{_, {_from, ^target, false}}, _q} ->
        n

      {{_, {from, curr, pulse}}, q} ->
        module = modules[curr]
        outputs = elem(module, 1)

        {pulse, module} =
          case module do
            {:ff, outputs, state} ->
              if pulse do
                {nil, module}
              else
                state = not state
                {state, {:ff, outputs, state}}
              end

            {:conj, outputs, inputs} ->
              inputs = Map.put(inputs, from, pulse)
              pulse = not Enum.all?(inputs, fn {_, v} -> v end)
              {pulse, {:conj, outputs, inputs}}

            _ ->
              {false, module}
          end

        modules = Map.put(modules, curr, module)

        if pulse == nil do
          bfs2(q, modules, target, n)
        else
          outputs
          |> Enum.reduce(q, fn to, q ->
            :queue.snoc(q, {curr, to, pulse})
          end)
          |> bfs2(modules, target, n)
        end
    end
  end

  def update_count({lo, hi}, false), do: {lo + 1, hi}
  def update_count({lo, hi}, true), do: {lo, hi + 1}

  def input() do
    File.stream!("./input.txt")
    |> Enum.reduce(%{}, fn s, acc ->
      [lft, rht] = s |> String.trim() |> String.split(" -> ")
      outputs = rht |> String.split(", ")

      {sym, name} = String.split_at(lft, 1)
      name = if sym == "b", do: lft, else: name

      case sym do
        "%" ->
          {:ff, outputs, false}

        "&" ->
          {:conj, outputs, %{}}

        _ ->
          {:boardcast, outputs}
      end
      |> then(fn m -> Map.put(acc, name, m) end)
    end)
    |> add_inputs()
  end

  def add_inputs(modules) do
    modules
    |> Enum.reduce(modules, fn {from, v}, acc ->
      elem(v, 1)
      |> Enum.reduce(acc, fn to, acc ->
        case acc[to] do
          # rx
          nil ->
            Map.put(acc, to, {:unknown, [], [from]})

          {:conj, outputs, inputs} ->
            inputs = Map.put(inputs, from, false)
            Map.put(acc, to, {:conj, outputs, inputs})

          _ ->
            acc
        end
      end)
    end)
  end
end
