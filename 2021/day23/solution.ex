defmodule Solution do
  @room_xs 2..8//2
  @hallway Enum.reject(0..10, fn y -> y in @room_xs end) |> Enum.map(fn y -> {0, y} end)

  def part1(), do: run()

  def part2(), do: run(true)

  def run(extra? \\ false) do
    {0, init_state(extra?)}
    |> :gb_sets.add(:gb_sets.new())
    |> dijkstra(%{})
  end

  def dijkstra(pq, seen) do
    {{cost, state}, pq} = :gb_sets.take_smallest(pq)

    cond do
      finished?(state) ->
        cost

      seen[state] != nil and seen[state] <= cost ->
        dijkstra(pq, seen)

      true ->
        seen = Map.put(seen, state, cost)

        state
        |> valid_moves()
        |> Enum.reduce(pq, fn mv, pq ->
          {c, state} = move(mv, state)
          :gb_sets.add({c + cost, state}, pq)
        end)
        |> dijkstra(seen)
    end
  end

  def valid_moves(state) do
    max_x = max_x(state)

    state
    |> pods()
    |> Enum.reject(&in_target?(&1, state))
    |> Enum.map(fn {from, pod} ->
      ty = y(pod)

      if in_hallway?(from) do
        if Enum.all?(1..max_x, fn x -> state[{x, ty}] in [nil, pod] end) do
          Enum.find_value(max_x..1, fn x ->
            can_move?(from, {x, ty}, state) && {from, {x, ty}}
          end)
        end
      else
        @hallway
        |> Enum.filter(&can_move?(from, &1, state))
        |> Enum.map(fn to -> [{from, to}] end)
      end
    end)
    |> List.flatten()
    |> Enum.reject(&is_nil/1)
  end

  def in_target?({{x, y}, pod}, state) do
    y == y(pod) and Enum.all?(x..max_x(state), fn x -> state[{x, y}] == pod end)
  end

  def max_x(state) do
    state |> Map.keys() |> Enum.map(&elem(&1, 0)) |> Enum.max()
  end

  def in_hallway?({x, _}), do: x == 0

  def can_move?(from = {x1, y1}, {x2, y2}, state) do
    {dx, dy} = if x1 < x2, do: {x1, y2}, else: {x2, y1}

    v = y1..y2 |> Enum.map(fn y -> {dx, y} end)
    h = x1..x2 |> Enum.map(fn x -> {x, dy} end)

    Enum.concat(v, h)
    |> List.delete(from)
    |> Enum.all?(fn p -> state[p] == nil end)
  end

  def move({from, to}, state) do
    pod = state[from]
    dist = manhattan(from, to)
    cost = dist * cost(pod)
    state = state |> Map.put(from, nil) |> Map.put(to, pod)
    {cost, state}
  end

  def cost(pod) do
    case pod do
      "A" -> 1
      "B" -> 10
      "C" -> 100
      "D" -> 1000
    end
  end

  def manhattan({x1, y1}, {x2, y2}) do
    abs(x1 - x2) + abs(y1 - y2)
  end

  def finished?(state) do
    state
    |> pods()
    |> Enum.all?(fn {{x, y}, pod} ->
      x > 0 and y == y(pod)
    end)
  end

  def pods(state) do
    Map.filter(state, fn {_, v} -> v != nil end)
  end

  def y("A"), do: 2
  def y("B"), do: 4
  def y("C"), do: 6
  def y("D"), do: 8

  def init_state(extra?) do
    hallway = @hallway |> Map.new(fn p -> {p, nil} end)

    input(extra?) |> Map.merge(hallway)
  end

  def input(extra?) do
    content =
      if extra? do
        {h, t} =
          File.read!("input.txt")
          |> String.split("\n")
          |> Enum.split(3)

        [h, "  #D#C#B#A#", "  #D#B#A#C#", t]
        |> List.flatten()
        |> Enum.join("\n")
      else
        File.read!("input.txt")
      end

    Regex.scan(~r/[A-Z]/, content)
    |> Enum.map(&hd/1)
    |> Enum.chunk_every(4)
    |> Enum.with_index(1)
    |> Enum.map(fn {r, x} ->
      Enum.zip(r, @room_xs)
      |> Enum.map(fn {pod, y} -> {{x, y}, pod} end)
    end)
    |> List.flatten()
    |> Map.new()
  end
end
