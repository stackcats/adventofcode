defmodule Solution do
  @spring_position {0, 500}

  def part1() do
    grid = input() |> Map.put(@spring_position, "+")

    IO.inspect(grid_border(grid))

    dfs(grid, @spring_position, grid_border(grid))
    |> tap(&print/1)
    |> Map.values()
    |> Enum.count(fn c -> c in ["|", "~"] end)
  end

  def dfs(grid, {i, j}, {u, d, l, r}) when i < u or i > d or j < l or j > r do
    grid
  end

  def dfs(grid, {i, j}, {u, d, l, r}) do
    print(grid)
    IO.gets("enter")

    c = grid[{i + 1, j}]

    IO.inspect({i, j})

    cond do
      # grid[{i, j}] in ["#", "~"] ->
      #   grid

      c in ["#", "~"] ->
        left = check_left(grid, {i, j}, l)
        right = check_right(grid, {i, j}, r)
        IO.inspect({left, right})

        case {left, right} do
          {nil, nil} ->
            grid =
              if grid[{i, j - 1}] == nil do
                grid
                |> Map.put({i, j - 1}, "|")
                |> dfs({i, j - 1}, {u, d, l, r})
              else
                grid
              end

            if grid[{i, j + 1}] == nil do
              grid
              |> Map.put({i, j + 1}, "|")
              |> dfs({i, j + 1}, {u, d, l, r})
            else
              grid
            end

          # |> dfs({i, j + 1}, {u, d, l, r})

          {left, nil} ->
            for k <- left..(j - 1), reduce: grid do
              acc -> Map.put(acc, {i, k}, "|")
            end
            |> dfs({i, j + 1}, {u, d, l, r})

          {nil, right} ->
            for k <- (j + 1)..right, reduce: grid do
              acc -> Map.put(acc, {i, k}, "|")
            end
            |> dfs({i, j - 1}, {u, d, l, r})

          {left, right} ->
            for k <- left..right, reduce: grid do
              acc -> Map.put(acc, {i, k}, "~")
            end
            |> dfs({i - 1, j}, {u, d, l, r})
        end

      c == nil ->
        Map.put(grid, {i + 1, j}, "|")
        |> dfs({i + 1, j}, {u, d, l, r})
    end
  end

  def check_left(grid, {i, j}, l) do
    cond do
      j < l || grid[{i, j - 1}] == "|" -> nil
      grid[{i + 1, j}] in ["#", "~"] && grid[{i, j - 1}] == "#" -> j
      grid[{i + 1, j}] in ["#", "~"] && grid[{i, j - 1}] == nil -> check_left(grid, {i, j - 1}, l)
      true -> nil
    end
  end

  def check_right(grid, {i, j}, r) do
    cond do
      j > r || grid[{i, j + 1}] == "|" -> nil
      grid[{i + 1, j}] in ["#", "~"] && grid[{i, j + 1}] == "#" -> j
      grid[{i + 1, j}] in ["#", "~"] && grid[{i, j + 1}] == nil -> check_left(grid, {i, j + 1}, r)
      true -> nil
    end
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(fn s ->
      [p, l, r] =
        Regex.scan(~r/\d+/, s)
        |> Enum.flat_map(fn x -> x |> Enum.map(&String.to_integer/1) end)

      if String.starts_with?(s, "x"), do: {l..r, p}, else: {p, l..r}
    end)
    |> Enum.reduce(%{}, fn {y, x}, acc ->
      if is_integer(y) do
        for i <- x, reduce: acc do
          acc -> Map.put(acc, {y, i}, "#")
        end
      else
        for i <- y, reduce: acc do
          acc -> Map.put(acc, {i, x}, "#")
        end
      end
    end)
  end

  def grid_border(grid) do
    grid
    |> Enum.reduce({10000, 0, 10000, 0}, fn {{y, x}, _}, {u, d, l, r} ->
      {min(u, y), max(d, y), min(l, x), max(r, x)}
    end)
  end

  def print(grid) do
    {u, d, l, r} = grid_border(grid)

    for i <- u..d do
      for j <- (l - 1)..(r + 1) do
        IO.write(Map.get(grid, {i, j}, " "))
      end

      IO.puts("")
    end

    IO.puts("")
  end
end
