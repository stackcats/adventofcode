defmodule Solution do
  def what_floor do
    {:ok, file} = File.open("./input.txt", [:read])

    IO.read(file, :all)
    |> String.trim()
    |> String.graphemes()
    |> Enum.reduce(0, fn ch, acc -> if ch == "(", do: acc + 1, else: acc - 1 end)
  end
end
