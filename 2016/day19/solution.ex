defmodule Solution do
  @target 3_012_210
  def part1() do
    part1(1, @target)
  end

  def part1(n, target) do
    if target > n do
      part1(n * 2, target - n)
    else
      target * 2 - 1
    end
  end

  def part2() do
    part2(1, @target)
  end

  def part2(n, target) do
    if target > n * 3 do
      part2(n * 3, target)
    else
      target - n
    end
  end
end
