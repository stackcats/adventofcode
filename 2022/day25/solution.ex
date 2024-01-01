defmodule Solution do
  def part1() do
    input()
    |> Stream.map(fn xs ->
      xs
      |> Enum.reverse()
      |> Enum.reduce({0, 0}, fn x, {acc, p} ->
        {acc + x * 5 ** p, p + 1}
      end)
      |> elem(0)
    end)
    |> Enum.sum()
    |> to_snafu("")
  end

  def to_snafu(0, snafu), do: snafu

  def to_snafu(n, snafu) do
    case rem(n, 5) do
      4 -> to_snafu(div(n + 1, 5), "-" <> snafu)
      3 -> to_snafu(div(n + 2, 5), "=" <> snafu)
      r -> to_snafu(div(n, 5), "#{r}" <> snafu)
    end
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.graphemes/1)
    |> Stream.map(fn xs ->
      xs
      |> Enum.map(fn x ->
        case x do
          "-" -> -1
          "=" -> -2
          _ -> String.to_integer(x)
        end
      end)
    end)
  end
end
