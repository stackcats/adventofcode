defmodule Solution do
  @len 10

  def part1() do
    m = input() |> to_map()

    for _i <- 0..99, reduce: {m, 0} do
      {acc, ct} -> step(acc, ct)
    end
    |> elem(1)
  end

  def part2() do
    input()
    |> to_map()
    |> wait_all_flash(0)
  end

  defp wait_all_flash(m, i) do
    if all_flash?(m) do
      i
    else
      step(m, 0)
      |> elem(0)
      |> wait_all_flash(i + 1)
    end
  end

  defp step(m, ct) do
    update_all(m) |> flash(ct)
  end

  defp update_all(m) do
    for i <- 0..(@len - 1), j <- 0..(@len - 1), reduce: m do
      acc -> update(acc, {i, j})
    end
  end

  defp flash(m, ct) do
    for i <- 0..(@len - 1), j <- 0..(@len - 1), reduce: {m, ct} do
      {acc, ct} ->
        if acc[{i, j}] == 10 do
          {Map.put(acc, {i, j}, 0), ct + 1}
        else
          {acc, ct}
        end
    end
  end

  defp all_flash?(m) do
    for i <- 0..(@len - 1), j <- 0..(@len - 1), m[{i, j}] == 0 do
      m[{i, j}]
    end
    |> Enum.count() == @len * @len
  end

  defp update(m, {i, j}) do
    if Map.get(m, {i, j}, 10) == 10 do
      m
    else
      m = Map.update!(m, {i, j}, &(&1 + 1))

      if m[{i, j}] > 9 do
        m
        |> update({i - 1, j - 1})
        |> update({i - 1, j})
        |> update({i - 1, j + 1})
        |> update({i, j + 1})
        |> update({i + 1, j + 1})
        |> update({i + 1, j})
        |> update({i + 1, j - 1})
        |> update({i, j - 1})
      else
        m
      end
    end
  end

  defp input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.graphemes/1)
    |> Stream.map(fn line -> Enum.map(line, &String.to_integer/1) end)
    |> Enum.to_list()
  end

  defp to_map(lst) do
    lst
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {row, i}, m ->
      Enum.with_index(row)
      |> Enum.reduce(m, fn {n, j}, m ->
        Map.put(m, {i, j}, n)
      end)
    end)
  end
end
