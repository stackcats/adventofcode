defmodule Solution do
  defmodule DSet do
    defstruct root: %{}, rank: %{}

    def new(), do: %DSet{}

    def find(ds, x) do
      cond do
        ds.root[x] == nil ->
          {x, %{ds | root: Map.put(ds.root, x, x), rank: Map.put(ds.rank, x, 1)}}

        ds.root[x] == x ->
          {x, ds}

        true ->
          {r, ds} = find(ds, ds.root[x])
          {r, %{ds | root: Map.put(ds.root, x, r)}}
      end
    end

    def union(ds, x, y) do
      {rootX, ds} = find(ds, x)
      {rootY, ds} = find(ds, y)

      cond do
        rootX == rootY ->
          ds

        ds.root[rootX] > ds.root[rootY] ->
          %{ds | root: Map.put(ds.root, rootY, rootX)}

        ds.root[rootX] < ds.root[rootY] ->
          %{ds | root: Map.put(ds.root, rootX, rootY)}

        true ->
          %DSet{
            root: Map.put(ds.root, rootX, rootY),
            rank: Map.update!(ds.rank, rootX, &(&1 + 1))
          }
      end
    end
  end

  def part1() do
    lst = input()

    {r, ds} = lst |> aux() |> DSet.find("0")

    lst
    |> Enum.reduce({0, ds}, fn {id, _}, {ct, ds} ->
      {r1, ds} = DSet.find(ds, id)
      ct = if r1 == r, do: ct + 1, else: ct
      {ct, ds}
    end)
    |> elem(0)
  end

  def part2() do
    lst = input()
    ds = aux(lst)

    lst
    |> Enum.reduce({MapSet.new(), ds}, fn {id, _}, {set, ds} ->
      {r, ds} = DSet.find(ds, id)
      {MapSet.put(set, r), ds}
    end)
    |> elem(0)
    |> MapSet.size()
  end

  def aux(lst) do
    lst
    |> Enum.reduce(DSet.new(), fn {id, xs}, set ->
      xs |> Enum.reduce(set, fn x, set -> DSet.union(set, x, id) end)
    end)
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.replace(&1, " ", ""))
    |> Stream.map(fn s ->
      [id, neighbors] = s |> String.split("<->")
      {id, String.split(neighbors, ",")}
    end)
    |> Enum.to_list()
  end
end
