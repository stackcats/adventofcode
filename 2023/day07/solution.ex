defmodule Solution do
  @cards ["2", "3", "4", "5", "6", "7", "8", "9", "T", "J", "Q", "K", "A"]
  @cardsj ["J", "2", "3", "4", "5", "6", "7", "8", "9", "T", "Q", "K", "A"]

  def part1() do
    input()
    |> Enum.sort(fn {hand1, type1, _, _}, {hand2, type2, _, _} ->
      compare_hand({hand1, type1}, {hand2, type2}, @cards)
    end)
    |> total_winnings()
  end

  def part2() do
    input()
    |> Enum.sort(fn {hand1, _, type1, _}, {hand2, _, type2, _} ->
      compare_hand({hand1, type1}, {hand2, type2}, @cardsj)
    end)
    |> total_winnings()
  end

  def total_winnings(hands) do
    hands
    |> Enum.with_index()
    |> Enum.reduce(0, fn {{_, _, _, bid}, i}, acc ->
      acc + bid * (i + 1)
    end)
  end

  def compare_hand({hand1, type1}, {hand2, type2}, card_order) do
    cond do
      type1 < type2 ->
        true

      type1 > type2 ->
        false

      true ->
        idx1 = Enum.map(hand1, fn h -> Enum.find_index(card_order, &(&1 == h)) end)
        idx2 = Enum.map(hand2, fn h -> Enum.find_index(card_order, &(&1 == h)) end)
        idx1 <= idx2
    end
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(fn s ->
      [hand, bid] = s |> String.trim() |> String.split(" ")
      hand = String.graphemes(hand)
      replaced = replace_joker(hand)
      {hand, hand_to_type(hand), hand_to_type(replaced), String.to_integer(bid)}
    end)
    |> Enum.to_list()
  end

  def replace_joker(hand) do
    st = MapSet.new(hand)

    if MapSet.member?(st, "J") do
      st
      |> MapSet.delete("J")
      |> Enum.map(fn c ->
        hand
        |> Enum.join("")
        |> String.replace("J", c)
        |> String.graphemes()
      end)
      |> Enum.sort(fn h1, h2 ->
        compare_hand({h1, hand_to_type(h1)}, {h2, hand_to_type(h2)}, @cards)
      end)
      |> List.last(hand)
    else
      hand
    end
  end

  def count(hand) do
    hand
    |> Enum.reduce(%{}, fn c, acc ->
      Map.update(acc, c, 1, &(&1 + 1))
    end)
    |> Map.values()
    |> Enum.sort()
  end

  def hand_to_type(hand) do
    case count(hand) do
      [5] -> 7
      [1, 4] -> 6
      [2, 3] -> 5
      [1, 1, 3] -> 4
      [1, 2, 2] -> 3
      [1, 1, 1, 2] -> 2
      _ -> 1
    end
  end
end
