defmodule Solution do
  @molecule "CRnCaCaCaSiRnBPTiMgArSiRnSiRnMgArSiRnCaFArTiTiBSiThFYCaFArCaCaSiThCaPBSiThSiThCaCaPTiRnPBSiThRnFArArCaCaSiThCaSiThSiRnMgArCaPTiBPRnFArSiThCaSiRnFArBCaSiRnCaPRnFArPMgYCaFArCaPTiTiTiBPBSiThCaPTiBPBSiRnFArBPBSiRnCaFArBPRnSiRnFArRnSiRnBFArCaFArCaCaCaSiThSiThCaCaPBPTiTiRnFArCaPTiBSiAlArPBCaCaCaCaCaSiRnMgArCaSiThFArThCaSiThCaSiRnCaFYCaSiRnFYFArFArCaSiRnFYFArCaSiRnBPMgArSiThPRnFArCaSiRnFArTiRnSiRnFYFArCaSiRnBFArCaSiRnTiMgArSiThCaSiThCaFArPRnFArSiRnFArTiTiTiTiBCaCaSiRnCaCaFYFArSiThCaPTiBPTiBCaSiThSiRnMgArCaF"

  def part1() do
    len = String.length(@molecule) - 1
    replacements = input()

    for i <- 0..len, reduce: MapSet.new() do
      acc ->
        {prefix, suffix} = String.split_at(@molecule, i)

        replacements
        |> Enum.reduce(acc, fn {k, vs}, acc ->
          if String.starts_with?(suffix, k) do
            Enum.reduce(vs, acc, fn v, acc ->
              MapSet.put(acc, prefix <> String.replace_prefix(suffix, k, v))
            end)
          else
            acc
          end
        end)
    end
    |> MapSet.size()
  end

  def part2() do
    input()
    |> Enum.reduce([], fn {k, vs}, acc ->
      Enum.reduce(vs, acc, fn v, acc -> [{k, v} | acc] end)
    end)
    |> replace(@molecule, 0)
  end

  def replace(_, "e", ct), do: ct

  def replace(replacements, source, ct) do
    {ct, replaced} =
      replacements
      |> Enum.reduce({ct, source}, fn {k, v}, {ct, source} ->
        if String.contains?(source, v) do
          {ct + 1, String.replace(source, v, k, global: false)}
        else
          {ct, source}
        end
      end)

    if replaced == source do
      replace(Enum.shuffle(replacements), @molecule, 0)
    else
      replace(replacements, replaced, ct)
    end
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.replace(&1, " ", ""))
    |> Stream.map(&String.split(&1, "=>"))
    |> Enum.reduce(%{}, fn [a, b], acc ->
      Map.update(acc, a, [b], &[b | &1])
    end)
  end
end
