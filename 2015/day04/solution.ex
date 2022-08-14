defmodule Solution do
  def five_zeroes() do
    aux("ckczppom", 1, "00000")
  end

  def six_zeroes() do
    aux("ckczppom", 1, "000000")
  end

  defp aux(s, n, target) do
    t = :crypto.hash(:md5, "#{s}#{n}") |> Base.encode16(case: :lower)

    if String.starts_with?(t, target) do
      n
    else
      aux(s, n + 1, target)
    end
  end
end
