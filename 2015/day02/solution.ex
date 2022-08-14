defmodule Solution do
  def square_feet_of_wrapping_paper do
    input()
    |> Enum.reduce(0, fn [a, b, c], acc ->
      acc + a * b * 3 + a * c * 2 + b * c * 2
    end)
  end

  def feet_of_ribbon do
    input()
    |> Enum.reduce(0, fn [a, b, c], acc ->
      acc + a + a + b + b + a * b * c
    end)
  end

  defp input() do
    File.stream!("./input.txt")
    |> Stream.map(fn s ->
      s
      |> String.strip()
      |> String.split("x")
      |> Enum.map(&String.to_integer/1)
      |> Enum.sort()
    end)
    |> Enum.to_list()
  end
end
