defmodule Solution do
  @state %{
    1 => %{chips: MapSet.new(["S", "P"]), rtgs: MapSet.new(["S", "P"])},
    2 => %{chips: MapSet.new(["R", "C"]), rtgs: MapSet.new(["T", "R", "C"])},
    3 => %{chips: MapSet.new(["T"]), rtgs: MapSet.new()},
    4 => %{chips: MapSet.new(), rtgs: MapSet.new()}
  }

  def part1() do
    @state
    |> init()
    |> run(MapSet.new())
  end

  def part2() do
    @state
    |> add_items([chip: "E", chip: "D", rtg: "E", rtg: "D"], 1)
    |> init()
    |> run(MapSet.new())
  end

  def init(state) do
    state[1]
    |> pick_items()
    |> Enum.reduce(:queue.new(), fn items, q ->
      remove_items(state, items, 1)
      |> neighbors(1, items, 1, q)
    end)
  end

  def run(q, visited) do
    {f, items, state, steps} = :queue.head(q)
    q = :queue.tail(q)

    state = add_items(state, items, f)

    key = count_items(state)

    cond do
      MapSet.member?(visited, {f, key}) ->
        run(q, visited)

      not compatible?(state[f]) ->
        run(q, visited)

      done?(state) ->
        steps

      true ->
        state[f]
        |> pick_items()
        |> Enum.reduce(q, fn items, q ->
          remove_items(state, items, f)
          |> neighbors(f, items, steps + 1, q)
        end)
        |> run(MapSet.put(visited, {f, key}))
    end
  end

  def neighbors(state, f, items, steps, q) do
    if compatible?(state[f]) do
      case f do
        1 ->
          q |> :queue.snoc({f + 1, items, state, steps})

        4 ->
          q |> :queue.snoc({f - 1, items, state, steps})

        _ ->
          q
          |> :queue.snoc({f - 1, items, state, steps})
          |> :queue.snoc({f + 1, items, state, steps})
      end
    else
      q
    end
  end

  def count_items(state) do
    1..4
    |> Enum.map(fn f ->
      {MapSet.size(state[f].chips), MapSet.size(state[f].rtgs)}
    end)
  end

  def pick_items(%{chips: chips, rtgs: rtgs}) do
    cs = chips |> MapSet.to_list() |> Enum.map(fn x -> {:chip, x} end)
    rs = rtgs |> MapSet.to_list() |> Enum.map(fn x -> {:rtg, x} end)
    items = cs ++ rs
    combo(items, 1) ++ combo(items, 2)
  end

  def add_items(state, items, f), do: move_items(state, items, f, &MapSet.put/2)

  def remove_items(state, items, f), do: move_items(state, items, f, &MapSet.delete/2)

  def move_items(state, items, f, func) do
    items
    |> Enum.reduce(state, fn {type, x}, state ->
      Map.update!(state, f, fn %{chips: chips, rtgs: rtgs} ->
        case type do
          :chip -> %{chips: func.(chips, x), rtgs: rtgs}
          _ -> %{chips: chips, rtgs: func.(rtgs, x)}
        end
      end)
    end)
  end

  def compatible?(%{chips: chips, rtgs: rtgs}) do
    MapSet.size(chips) == 0 ||
      MapSet.size(rtgs) == 0 ||
      Enum.all?(chips, &MapSet.member?(rtgs, &1))
  end

  def done?(state) do
    1..3
    |> Enum.all?(fn f ->
      MapSet.size(state[f].chips) == 0 && MapSet.size(state[f].rtgs) == 0
    end)
  end

  def combo(_, 0), do: [[]]
  def combo([], _), do: []

  def combo([h | t], n) do
    for(l <- combo(t, n - 1), do: [h | l]) ++ combo(t, n)
  end
end
