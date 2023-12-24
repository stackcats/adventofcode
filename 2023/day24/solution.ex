defmodule Solution do
  @left 200_000_000_000_000
  @right 400_000_000_000_000

  def part1() do
    # https://en.wikipedia.org/wiki/Line%E2%80%93line_intersection
    input() |> calc(0)
  end

  def calc([], ct), do: ct

  def calc([[x1, y1, _, x2, y2, _] | xs], ct) do
    xs
    |> Enum.reduce(ct, fn [x3, y3, _, x4, y4, _], acc ->
      d = x2 * y4 - y2 * x4

      if d == 0 do
        acc
      else
        t = ((x3 - x1) * y4 - (y3 - y1) * x4) / d
        u = ((x3 - x1) * y2 - (y3 - y1) * x2) / d
        px = x1 + t * x2
        py = y1 + t * y2

        if t >= 0 && u >= 0 &&
             px >= @left && px <= @right && py >= @left && py <= @right do
          acc + 1
        else
          acc
        end
      end
    end)
    |> then(fn ct ->
      calc(xs, ct)
    end)
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(fn s ->
      Regex.scan(~r/-?\d+/, s)
      |> Enum.map(fn m -> m |> hd() |> String.to_integer() end)
    end)
    |> Enum.to_list()
  end
end
