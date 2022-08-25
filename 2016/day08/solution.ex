defmodule Solution do
  @row 6
  @col 50

  def part1() do
    screen = gen_screen(@row, @col)

    input()
    |> Enum.reduce(screen, fn op, acc ->
      case op do
        {:rect, x, y} -> rect(acc, x, y)
        {:rotate_col, x, y} -> rotate_col(acc, x, y)
        {:rotate_row, x, y} -> rotate_row(acc, x, y)
        _ -> acc
      end
    end)
    |> tap(&print/1)
    |> Map.values()
    |> Enum.count(&(&1 == "#"))
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(fn s ->
      rect_reg = ~r/rect (?<y>\d+)x(?<x>\d+)/
      rotate_row_reg = ~r/rotate row y=(?<x>\d+) by (?<y>\d+)/
      rotate_col_reg = ~r/rotate column x=(?<x>\d+) by (?<y>\d+)/

      cond do
        Regex.match?(rect_reg, s) ->
          Regex.named_captures(rect_reg, s) |> pack(:rect)

        Regex.match?(rotate_row_reg, s) ->
          Regex.named_captures(rotate_row_reg, s) |> pack(:rotate_row)

        Regex.match?(rotate_col_reg, s) ->
          Regex.named_captures(rotate_col_reg, s) |> pack(:rotate_col)
      end
    end)
    |> Enum.to_list()
  end

  def pack(%{"x" => x, "y" => y}, op) do
    {op, String.to_integer(x), String.to_integer(y)}
  end

  def gen_screen(x, y) do
    for i <- 0..x, j <- 0..y, reduce: %{} do
      acc -> Map.put(acc, {i, j}, ".")
    end
  end

  def rect(map, x, y) do
    for i <- 0..(x - 1), j <- 0..(y - 1), reduce: map do
      acc -> Map.put(acc, {i, j}, "#")
    end
  end

  def rotate_col(map, col, step) do
    {h, t} =
      for i <- 0..(@row - 1) do
        map[{i, col}]
      end
      |> Enum.split(@row - step)

    lst = t ++ h

    for {i, pixel} <- Enum.zip(0..(@row - 1), lst), reduce: map do
      acc -> Map.put(acc, {i, col}, pixel)
    end
  end

  def rotate_row(map, row, step) do
    {h, t} =
      for i <- 0..(@col - 1) do
        map[{row, i}]
      end
      |> Enum.split(@col - step)

    lst = t ++ h

    for {i, pixel} <- Enum.zip(0..(@col - 1), lst), reduce: map do
      acc -> Map.put(acc, {row, i}, pixel)
    end
  end

  def print(acc) do
    for i <- 0..(@row - 1) do
      for j <- 0..(@col - 1) do
        IO.write(acc[{i, j}])
      end

      IO.puts("")
    end

    IO.puts("")
  end
end
