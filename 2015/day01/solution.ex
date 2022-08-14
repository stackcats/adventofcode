defmodule Solution do
  def what_floor do
    input()
    |> String.graphemes()
    |> Enum.reduce(0, fn ch, acc -> if ch == "(", do: acc + 1, else: acc - 1 end)
  end

  def position() do
    input()
    |> String.graphemes()
    |> position_aux(0, 0)
  end

  defp input() do
    {:ok, file} = File.open("./input.txt", [:read])
    IO.read(file, :all) |> String.trim()
  end

  defp position_aux(_, -1, p), do: p

  defp position_aux([], _, p), do: p

  defp position_aux(["(" | rest], floors, p) do
    position_aux(rest, floors + 1, p + 1)
  end

  defp position_aux([")" | rest], floors, p) do
    position_aux(rest, floors - 1, p + 1)
  end
end
