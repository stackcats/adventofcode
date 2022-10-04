defmodule Solution do
  def part1() do
    fetch_guard(fn {_, v} -> v |> Map.values() |> Enum.sum() end)
  end

  def part2() do
    fetch_guard(fn {_, v} -> v |> Map.values() |> Enum.max() end)
  end

  def fetch_guard(f) do
    gen_guards()
    |> Enum.max_by(f)
    |> then(fn {k, v} ->
      v
      |> Enum.max_by(fn {_, ct} -> ct end)
      |> then(fn {m, _} -> k * m end)
    end)
  end

  def gen_guards() do
    input()
    |> Enum.reduce({%{}, -1, 0}, fn {_, _, mm, event}, {guards, no, sleep_time} ->
      case event do
        {"shift", n} ->
          {guards, n, sleep_time}

        "falls asleep" ->
          {guards, no, mm}

        "wakes up" ->
          for m <- sleep_time..(mm - 1), reduce: Map.get(guards, no, %{}) do
            acc ->
              Map.update(acc, m, 1, &(&1 + 1))
          end
          |> then(fn guard ->
            {Map.put(guards, no, guard), no, 0}
          end)
      end
    end)
    |> elem(0)
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(fn s ->
      reg = ~r/\[(?<date>[-0-9]+) (?<hh>(\d\d)):(?<mm>\d\d)\] (?<event>.*)/

      Regex.named_captures(reg, s)
      |> then(fn cap ->
        event =
          if String.starts_with?(cap["event"], "Guard") do
            Regex.named_captures(~r/Guard #(?<no>\d+) begins shift/, cap["event"])
            |> then(fn m -> {"shift", String.to_integer(m["no"])} end)
          else
            cap["event"]
          end

        {cap["date"], String.to_integer(cap["hh"]), String.to_integer(cap["mm"]), event}
      end)
    end)
    |> Enum.to_list()
    |> Enum.sort()
  end
end
