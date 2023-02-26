defmodule Solution do
  @init_vel [0, 0, 0, 0]

  def part1() do
    input()
    |> Enum.map(fn xs ->
      1..1000
      |> Enum.reduce({xs, @init_vel}, fn _, {pos, vel} -> move(pos, vel) end)
    end)
    |> Enum.map(fn {pos, vel} ->
      {pos |> Enum.map(&elem(&1, 0)), vel}
    end)
    |> Enum.unzip()
    |> then(fn {pos, vel} ->
      pos = transpose(pos)
      vel = transpose(vel)

      Enum.zip(pos, vel)
      |> Enum.map(fn {pos, vel} ->
        pot =
          pos
          |> Enum.reduce(0, &(abs(&1) + &2))

        kin =
          vel
          |> Enum.reduce(0, &(abs(&1) + &2))

        pot * kin
      end)
      |> Enum.sum()
    end)
  end

  def part2() do
    input()
    |> Enum.map(fn xs -> repeat(xs, @init_vel, xs, 1) end)
    |> Enum.reduce(fn step, acc ->
      (step * acc) |> div(Integer.gcd(step, acc))
    end)
  end

  def repeat(pos, vel, init_pos, steps) do
    {pos, vel} = move(pos, vel)

    if {pos, vel} == {init_pos, @init_vel} do
      steps
    else
      repeat(pos, vel, init_pos, steps + 1)
    end
  end

  def move(pos, vel) do
    vel =
      Enum.zip(pos, vel)
      |> Enum.map(fn {{p, i}, v} ->
        pos
        |> Enum.reduce(v, fn {other, j}, acc ->
          cond do
            i == j || other == p -> acc
            other > p -> acc + 1
            other < p -> acc - 1
          end
        end)
      end)

    pos =
      Enum.zip(pos, vel)
      |> Enum.map(fn {{p, i}, v} ->
        {p + v, i}
      end)

    {pos, vel}
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(fn line ->
      ~r/<x=(-?\d+), y=(-?\d+), z=(-?\d+)>/
      |> Regex.run(line)
      |> tl()
      |> Enum.map(&String.to_integer/1)
    end)
    |> Enum.to_list()
    |> transpose()
    |> Enum.map(&Enum.with_index/1)
  end

  def transpose(mat) do
    mat
    |> List.zip()
    |> Enum.map(&Tuple.to_list/1)
  end
end
