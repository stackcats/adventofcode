defmodule Solution do
  defmodule Player do
    defstruct pos: 0, score: 0

    def new(pos) do
      %Player{pos: pos}
    end

    def win?(p, score) do
      p.score >= score
    end

    def play(p, dice) do
      pos = rem(p.pos + dice - 1, 10) + 1
      %{p | pos: pos, score: p.score + pos}
    end
  end

  def part1() do
    init() |> practice(1, 0)
  end

  def part2() do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
    Agent.update(__MODULE__, fn _ -> %{} end)

    init() |> play() |> Enum.max()
  end

  def init() do
    [_, pos1, _, pos2] = input()

    %{
      p1: Player.new(pos1),
      p2: Player.new(pos2),
      p1?: true
    }
  end

  def play(state) do
    cache = Agent.get(__MODULE__, fn mp -> mp[state] end)

    cond do
      Player.win?(state.p1, 21) ->
        [1, 0]

      Player.win?(state.p2, 21) ->
        [0, 1]

      cache != nil ->
        cache

      true ->
        quantum_die_freq()
        |> Enum.reduce([0, 0], fn {dice, freq}, [w1, w2] ->
          [r1, r2] = state |> next(dice) |> play()
          [w1 + r1 * freq, w2 + r2 * freq]
        end)
        |> tap(fn v -> Agent.update(__MODULE__, fn mp -> Map.put(mp, state, v) end) end)
    end
  end

  def next(state, dice) do
    if state.p1? do
      %{state | p1: Player.play(state.p1, dice), p1?: false}
    else
      %{state | p2: Player.play(state.p2, dice), p1?: true}
    end
  end

  def practice(state, die, ct) do
    cond do
      Player.win?(state.p1, 1000) ->
        state.p2.score * ct

      Player.win?(state.p2, 1000) ->
        state.p1.score * ct

      true ->
        dice = die + die + 1 + die + 2

        state
        |> next(dice)
        |> practice(rem(die + 2, 100) + 1, ct + 3)
    end
  end

  def quantum_die_freq() do
    for a <- 1..3, b <- 1..3, c <- 1..3 do
      a + b + c
    end
    |> Enum.frequencies()
  end

  def input() do
    content = File.read!("input.txt")

    Regex.scan(~r/\d+/, content)
    |> Enum.map(fn [n] -> String.to_integer(n) end)
  end
end
