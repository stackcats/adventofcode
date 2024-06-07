defmodule Solution do
  def part1() do
    ts =
      input()
      |> Map.new(fn {id, tile} -> {id, {tile, sides(tile)}} end)

    ts
    |> Map.filter(fn {id, {_, sides}} ->
      ts
      |> Map.delete(id)
      |> Enum.count(fn {_, {_, other}} ->
        MapSet.intersection(sides, other) |> MapSet.size() > 0
      end)
      |> then(&(&1 == 2))
    end)
    |> Map.keys()
    |> Enum.product()
  end

  def part2() do
    ts = input()
    size = map_size(ts) |> :math.sqrt() |> ceil()

    g =
      for i <- 1..size, j <- 1..size, reduce: {ts, %{}} do
        {ts, g} ->
          build_grid(ts, g, i - 1, j - 1)
      end
      |> elem(1)
      |> Map.new(fn {k, img} ->
        img
        |> Enum.drop(1)
        |> Enum.take(8)
        |> Enum.map(fn r -> r |> Enum.drop(1) |> Enum.take(8) end)
        |> then(&{k, &1})
      end)

    image =
      for i <- 1..size, j <- 1..size do
        g[{i - 1, j - 1}]
      end
      |> Enum.chunk_every(size)
      |> Enum.map(fn r ->
        Enum.zip(r)
        |> Enum.map(fn each -> Tuple.to_list(each) |> List.flatten() end)
      end)
      |> Enum.reduce(&Enum.concat(&2, &1))

    n = image |> List.flatten() |> Enum.count(&(&1 == "#"))
    m = MapSet.size(search_monster())

    image
    |> transform()
    |> Enum.map(fn img -> n - count_monsters(img) * m end)
    |> Enum.find(fn ct -> ct < n end)
  end

  def count_monsters(img) do
    size = length(img)

    st = to_set(img)

    monster = search_monster()

    for i <- 1..size, j <- 1..size, reduce: 0 do
      acc ->
        monster
        |> Enum.all?(fn {di, dj} -> {i + di - 1, j + dj - 1} in st end)
        |> if do
          acc + 1
        else
          acc
        end
    end
  end

  def search_monster() do
    """
                      # 
    #    ##    ##    ###
     #  #  #  #  #  #
    """
    |> String.split("\n", trim: true)
    |> Enum.map(&String.graphemes/1)
    |> to_set()
  end

  def to_set(lst) do
    lst
    |> Enum.with_index(0)
    |> Enum.reduce(%MapSet{}, fn {r, i}, acc ->
      r
      |> Enum.with_index(0)
      |> Enum.reduce(acc, fn {c, j}, acc ->
        if c == "#", do: MapSet.put(acc, {i, j}), else: acc
      end)
    end)
  end

  def transform(img) do
    a = rotate(img)
    b = rotate(a)
    c = rotate(b)
    [img, flip(img), a, flip(a), b, flip(b), c, flip(c)]
  end

  def build_grid(ts, g, 0, 0) do
    ts
    |> Enum.reduce_while(nil, fn {id, img}, acc ->
      all_sides =
        ts
        |> Map.delete(id)
        |> Enum.reduce(%MapSet{}, fn {_, img}, acc ->
          MapSet.union(acc, sides(img))
        end)

      transform(img)
      |> Enum.find(fn img ->
        [top, bottom, left, right] = edges(img)

        top not in all_sides and right in all_sides and bottom in all_sides and
          left not in all_sides
      end)
      |> case do
        nil -> {:cont, acc}
        img -> {:halt, {id, img}}
      end
    end)
    |> then(fn {id, img} ->
      {Map.delete(ts, id), Map.put(g, {0, 0}, img)}
    end)
  end

  def build_grid(ts, g, x, y) do
    target =
      case y do
        0 -> g[{x - 1, 0}] |> List.last()
        _ -> g[{x, y - 1}] |> right_side()
      end

    ts
    |> Enum.reduce_while(nil, fn {id, img}, acc ->
      transform(img)
      |> Enum.find(fn img ->
        case y do
          0 -> hd(img) == target
          _ -> left_side(img) == target
        end
      end)
      |> case do
        nil -> {:cont, acc}
        img -> {:halt, {id, img}}
      end
    end)
    |> then(fn {id, img} ->
      {Map.delete(ts, id), Map.put(g, {x, y}, img)}
    end)
  end

  def left_side(img), do: Enum.map(img, &hd/1)

  def right_side(img), do: Enum.map(img, &List.last/1)

  def edges(img) do
    [hd(img), List.last(img), left_side(img), right_side(img)]
  end

  def sides(img) do
    sides = edges(img)

    Enum.map(sides, &Enum.reverse/1)
    |> Enum.concat(sides)
    |> MapSet.new()
  end

  def flip(img) do
    img |> Enum.map(&Enum.reverse/1)
  end

  def rotate(img) do
    img |> Enum.zip() |> Enum.map(fn r -> Tuple.to_list(r) |> Enum.reverse() end)
  end

  def input() do
    File.read!("./input.txt")
    |> String.split("\n\n")
    |> Enum.map(fn s ->
      [id | tile] = s |> String.trim() |> String.split("\n")
      id = id |> String.replace(~r/[^0-9]/, "") |> String.to_integer()

      tile = tile |> Enum.map(&String.graphemes/1)

      {id, tile}
    end)
    |> Map.new()
  end
end
