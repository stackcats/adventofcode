defmodule Solution do
  @row 5
  @col 5

  def part1() do
    boards = read_boards()
    nums = read_numbers()
    mark(nums, boards, []) |> List.first()
  end

  def part2() do
    boards = read_boards()
    nums = read_numbers()
    mark(nums, boards, []) |> List.last()
  end

  defp read_numbers() do
    File.stream!("./numbers.txt")
    |> Stream.map(&String.trim/1)
    |> Enum.to_list()
    |> List.first()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  defp read_boards() do
    File.stream!("./boards.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.filter(&(&1 != ""))
    |> Stream.map(&String.split/1)
    |> Stream.chunk_every(@row)
    |> Stream.map(&build_board/1)
    |> Enum.to_list()
  end

  defp build_board(board) do
    arr =
      board
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {row, i}, acc ->
        row
        |> Enum.with_index()
        |> Enum.reduce(acc, fn {x, j}, acc ->
          Map.put(acc, {i, j}, String.to_integer(x))
        end)
      end)

    visited = arr |> Enum.reduce(%{}, fn {_, v}, acc -> Map.put(acc, v, false) end)

    {arr, visited}
  end

  defp mark([], _, ans), do: ans
  defp mark(_, [], ans), do: ans

  defp mark([n | rest], boards, ans) do
    {wins, boards} = boards |> Enum.map(&update_board(&1, n)) |> find_bingo([], [])
    scores = wins |> Enum.map(&(cal_board(&1) * n))
    mark(rest, boards, Enum.concat(ans, scores))
  end

  defp find_bingo([], wins, checked), do: {wins, checked}

  defp find_bingo([board | rest], wins, checked) do
    if is_bingo(board) do
      find_bingo(rest, wins ++ [board], checked)
    else
      find_bingo(rest, wins, [board | checked])
    end
  end

  defp cal_board({_, visited}) do
    visited
    |> Enum.flat_map(fn {k, v} -> if v == false, do: [k], else: [] end)
    |> Enum.sum()
  end

  defp update_board({arr, visited}, n) do
    if not Map.has_key?(visited, n) do
      {arr, visited}
    else
      {arr, Map.put(visited, n, true)}
    end
  end

  defp is_bingo(board) do
    0..(@row - 1) |> Enum.map(&is_row_marked(board, &1)) |> Enum.any?() ||
      0..(@col - 1) |> Enum.map(&is_col_marked(board, &1)) |> Enum.any?()
  end

  defp is_row_marked(board, r) do
    0..(@col - 1) |> Enum.map(&is_marked(board, r, &1)) |> Enum.all?()
  end

  defp is_col_marked(board, c) do
    0..(@row - 1) |> Enum.map(&is_marked(board, &1, c)) |> Enum.all?()
  end

  defp is_marked({arr, visited}, r, c) do
    n = arr[{r, c}]
    visited[n]
  end
end
