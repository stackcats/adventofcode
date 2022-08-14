defmodule Solution do
  def how_many_houses() do
    start_house = {0, 0}
    houses = MapSet.new([start_house])

    input()
    |> make_move(start_house, houses)
    |> MapSet.size()
  end

  defp make_move([], _house, houses), do: houses

  defp make_move([move | rest], house, houses) do
    new_house = next_house(house, move)
    make_move(rest, new_house, MapSet.put(houses, new_house))
  end

  def how_many_houses_with_robo_santa() do
    start_house = {0, 0}
    santa_houses = MapSet.new([start_house])
    robo_santa_houses = MapSet.new([start_house])

    {santa_houses, robo_santa_houses} =
      input()
      |> make_move_with_robo(true, start_house, start_house, santa_houses, robo_santa_houses)

    MapSet.union(santa_houses, robo_santa_houses) |> MapSet.size()
  end

  defp make_move_with_robo(
         [],
         _is_santa_turn,
         _santa_house,
         _robo_santa_house,
         santa_houses,
         robo_santa_houses
       ),
       do: {santa_houses, robo_santa_houses}

  defp make_move_with_robo(
         [move | rest],
         true,
         santa_house,
         robo_santa_house,
         santa_houses,
         robo_santa_houses
       ) do
    new_house = next_house(santa_house, move)

    make_move_with_robo(
      rest,
      false,
      new_house,
      robo_santa_house,
      MapSet.put(santa_houses, new_house),
      robo_santa_houses
    )
  end

  defp make_move_with_robo(
         [move | rest],
         false,
         santa_house,
         robo_santa_house,
         santa_houses,
         robo_santa_houses
       ) do
    new_house = next_house(robo_santa_house, move)

    make_move_with_robo(
      rest,
      true,
      santa_house,
      new_house,
      santa_houses,
      MapSet.put(robo_santa_houses, new_house)
    )
  end

  defp next_house({x, y}, move) do
    {dx, dy} =
      case move do
        "^" -> {-1, 0}
        ">" -> {0, 1}
        "v" -> {1, 0}
        "<" -> {0, -1}
        _ -> {0, 0}
      end

    {x + dx, y + dy}
  end

  defp input() do
    {:ok, file} = File.open("./input.txt", [:read])
    IO.read(file, :all) |> String.trim() |> String.graphemes()
  end
end
