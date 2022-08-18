defmodule Solution do
  @weapons %{
    "Dagger" => {8, 4, 0},
    "Shortsword" => {10, 5, 0},
    "Warhammer" => {25, 6, 0},
    "Longsword" => {40, 7, 0},
    "Greataxe" => {74, 8, 0}
  }

  @armor %{
    "Leather" => {13, 0, 1},
    "Chainmail" => {31, 0, 2},
    "Splintmail" => {53, 0, 3},
    "Longsword" => {75, 0, 4},
    "Bandedmail" => {102, 0, 5}
  }

  @rings %{
    "Damage +1" => {25, 1, 0},
    "Damage +2" => {50, 2, 0},
    "Damage +3" => {100, 3, 0},
    "Defense +1" => {20, 0, 1},
    "Defense +2" => {40, 0, 2},
    "Defense +3" => {80, 0, 3}
  }

  @boss {109, 8, 2, 0}

  def weapon_list() do
    Map.values(@weapons)
  end

  def armor_list() do
    [{0, 0, 0} | Map.values(@armor)]
  end

  def ring_list() do
    for i <- 0..2 do
      combo(Map.values(@rings), i)
    end
    |> Enum.concat()
  end

  def combo(_, 0), do: [[]]
  def combo([], _), do: []

  def combo([h | t], n) do
    for(l <- combo(t, n - 1), do: [h | l]) ++ combo(t, n)
  end

  def part1() do
    for w <- weapon_list(), a <- armor_list(), r <- ring_list() do
      equip(w, a, r)
    end
    |> Enum.filter(&win?(&1, @boss))
    |> Enum.min_by(&elem(&1, 3))
    |> elem(3)
  end

  def part2() do
    for w <- weapon_list(), a <- armor_list(), r <- ring_list() do
      equip(w, a, r)
    end
    |> Enum.filter(&(not win?(&1, @boss)))
    |> Enum.max_by(&elem(&1, 3))
    |> elem(3)
  end

  def equip(weapon, armor, rings) do
    c = attr(weapon, armor, rings, 0)
    d = attr(weapon, armor, rings, 1)
    a = attr(weapon, armor, rings, 2)
    {100, d, a, c}
  end

  def attr(weapon, armor, rings, n) do
    elem(weapon, n) + elem(armor, n) + Enum.reduce(rings, 0, fn r, acc -> elem(r, n) + acc end)
  end

  def win?(player, boss) do
    boss = attack(player, boss)
    player = attack(boss, player)

    cond do
      elem(boss, 0) <= 0 -> true
      elem(player, 0) <= 0 -> false
      true -> win?(player, boss)
    end
  end

  def attack({_, d1, _, _}, {h, d2, a, c}) do
    {h - max(1, d1 - a), d2, a, c}
  end
end
