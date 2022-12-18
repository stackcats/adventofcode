defmodule Solution do
  use Agent

  defmodule Valve do
    defstruct [:rate, :ns]

    def new(rate, ns) do
      %Valve{rate: rate, ns: ns}
    end
  end

  def part1() do
    init()

    reset()

    vals = input()

    dfs("AA", vals, 30)
  end

  def init() do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def reset() do
    Agent.update(__MODULE__, fn _ -> %{} end)
  end

  def get(k) do
    Agent.get(__MODULE__, fn cache -> cache[k] end)
  end

  def update(k, v) do
    Agent.update(__MODULE__, fn cache -> Map.put(cache, k, v) end)
  end

  def dfs(curr, vals, ct, opened \\ []) do
    cache_key = {curr, ct, opened}
    cache_val = get(cache_key)
    v = vals[curr]

    cond do
      cache_val != nil ->
        cache_val

      ct <= 0 ->
        0

      curr in opened ->
        v.ns
        |> Enum.reduce(0, fn adj, acc ->
          max(acc, dfs(adj, vals, ct - 1, opened))
        end)
        |> then(fn acc ->
          update(cache_key, acc)
          acc
        end)

      true ->
        pressure = v.rate * (ct - 1)
        curr_opened = Enum.sort([curr | opened])

        v.ns
        |> Enum.reduce(0, fn adj, acc ->
          p1 = if pressure > 0, do: dfs(adj, vals, ct - 2, curr_opened) + pressure, else: 0
          p2 = dfs(adj, vals, ct - 1, opened)
          [p1, p2, acc] |> Enum.max()
        end)
        |> then(fn acc ->
          update(cache_key, acc)
          acc
        end)
    end
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(fn s ->
      r =
        ~r/Valve (?<valve>[A-Z]{2}) has flow rate=(?<rate>\d*); tunnels? leads? to valves? (?<adj>.*)/

      Regex.named_captures(r, s)
      |> then(fn m ->
        valve = m["valve"]
        rate = String.to_integer(m["rate"])
        adj = String.split(m["adj"], ", ")
        {valve, Valve.new(rate, adj)}
      end)
    end)
    |> Map.new()
  end
end
