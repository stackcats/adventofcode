defmodule Solution do
  def part1() do
    input()
    |> count_trees(3, 1)
  end

  def part2() do
    mat = input()

    [[mat, 1, 1], [mat, 3, 1], [mat, 5, 1], [mat, 7, 1], [mat, 1, 2]]
    |> Enum.map(&apply(__MODULE__, :count_trees, &1))
    |> Enum.product()
  end

  def count_trees({m, r, c}, right, down) do
    for i <- 0..(r - 1)//down, reduce: {0, 0} do
      {ct, j} ->
        nj = rem(j + right, c)

        if m[{i, j}] == "#" do
          {ct + 1, nj}
        else
          {ct, nj}
        end
    end
    |> elem(0)
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.graphemes/1)
    |> Enum.to_list()
    |> to_map()
  end

  def to_map(lst) do
    r = Enum.count(lst)
    c = Enum.count(hd(lst))

    m =
      lst
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {row, i}, acc ->
        row
        |> Enum.with_index()
        |> Enum.reduce(acc, fn {n, j}, acc ->
          Map.put(acc, {i, j}, n)
        end)
      end)

    {m, r, c}
  end
end
