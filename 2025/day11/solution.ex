defmodule Solution do
  def part1() do
    g = input()

    dfs("you", true, true, g, %{})
    |> elem(0)
  end

  def part2() do
    g = input()

    dfs("svr", false, false, g, %{})
    |> elem(0)
  end

  def dfs(curr, fft?, dac?, g, memo) do
    key = {curr, fft?, dac?}

    case memo do
      %{^key => cached} ->
        {cached, memo}

      _ ->
        {result, memo} =
          cond do
            curr == "out" ->
              if fft? and dac?, do: {1, memo}, else: {0, memo}

            true ->
              Enum.reduce(g[curr], {0, memo}, fn nxt, {acc, memo} ->
                {cnt, memo} =
                  case nxt do
                    "fft" -> dfs("fft", true, dac?, g, memo)
                    "dac" -> dfs("dac", fft?, true, g, memo)
                    _ -> dfs(nxt, fft?, dac?, g, memo)
                  end

                {acc + cnt, memo}
              end)
          end

        {result, Map.put(memo, key, result)}
    end
  end

  def input() do
    File.read!("./input.txt")
    |> String.split("\n", trim: true)
    |> Enum.reduce(%{}, fn s, acc ->
      [f, t] = String.split(s, ": ")
      Map.put(acc, f, String.split(t, " "))
    end)
  end
end
