defmodule Solution do
  @range 172_930..683_082

  def part1() do
    find_password(fn xs -> length(xs) >= 2 end)
  end

  def part2() do
    find_password(fn xs -> length(xs) == 2 end)
  end

  def find_password(f) do
    @range
    |> Enum.count(fn n ->
      lst = num_to_list(n)
      non_decrease?(lst) && adjacent_same?(lst, f)
    end)
  end

  def num_to_list(n, lst \\ [])
  def num_to_list(0, lst), do: lst

  def num_to_list(n, lst) do
    num_to_list(div(n, 10), [rem(n, 10) | lst])
  end

  def non_decrease?(lst) do
    lst
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.all?(fn [a, b] -> a <= b end)
  end

  def adjacent_same?(lst, f) do
    lst
    |> Enum.reduce([], &split/2)
    |> Enum.any?(f)
  end

  def split(x, []), do: [[x]]
  def split(x, [[x | ys] | rest]), do: [[x, x | ys] | rest]
  def split(x, [[y | ys] | rest]), do: [[x], [y | ys] | rest]
end
