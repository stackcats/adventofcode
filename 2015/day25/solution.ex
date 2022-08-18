defmodule Solution do
  def part1() do
    aux(20_151_125, {1, 1}, {2978, 3083})
  end

  def aux(n, pos, target) do
    if pos == target do
      n
    else
      aux(rem(n * 252_533, 33_554_393), next(pos), target)
    end
  end

  def next({row, col}) do
    if row == 1 do
      {col + 1, 1}
    else
      {row - 1, col + 1}
    end
  end
end
