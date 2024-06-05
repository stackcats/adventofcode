defmodule Solution do
  @input 789_465_123

  def part1() do
    run(9, 100)
    |> to_num(1)
  end

  def part2() do
    run(1_000_000, 10_000_000, true)
    |> then(fn lst ->
      a = lst[1]
      a * lst[a]
    end)
  end

  def run(max, moves, extra? \\ false) do
    lst = @input |> Integer.digits()
    [x | xs] = if extra?, do: lst ++ Enum.to_list(10..max), else: lst

    Enum.zip([x | xs], xs ++ [x])
    |> Map.new()
    |> move(hd(lst), max, moves)
  end

  def to_num(lst, i) do
    n = lst[i]

    if n == 1, do: "", else: "#{n}" <> to_num(lst, n)
  end

  def move(lst, _, _, 0), do: lst

  def move(lst, curr, max, ct) do
    a = lst[curr]
    b = lst[a]
    c = lst[b]
    rest = lst[c]
    pickup = [a, b, c]
    dest = check_destination(curr - 1, max, pickup)
    next = Map.get(lst, dest)

    lst
    |> Map.put(curr, rest)
    |> Map.put(dest, a)
    |> Map.put(a, b)
    |> Map.put(b, c)
    |> Map.put(c, next)
    |> move(rest, max, ct - 1)
  end

  def check_destination(0, max, pickup) do
    check_destination(max, max, pickup)
  end

  def check_destination(n, max, pickup) do
    if n in pickup do
      check_destination(n - 1, max, pickup)
    else
      n
    end
  end
end
