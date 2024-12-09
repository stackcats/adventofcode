defmodule Solution do
  def part1() do
    disk = input() |> split(0) |> List.flatten()
    len = length(disk)

    disk
    |> Enum.with_index()
    |> Map.new(fn {id, i} -> {i, id} end)
    |> reorder(0, len - 1)
    |> checksum()
  end

  def part2() do
    disk = input() |> split(0) |> Enum.reject(&(&1 == []))

    last_id = disk |> List.last() |> hd()

    disk
    |> reorder_block(last_id)
    |> List.flatten()
    |> Enum.with_index()
    |> checksum()
  end

  def checksum(disk) do
    disk
    |> Enum.map(fn
      {_, -1} -> 0
      {-1, _} -> 0
      {a, b} -> a * b
    end)
    |> Enum.sum()
  end

  def reorder_block(disk, id) when id < 1, do: disk

  def reorder_block(disk, id) do
    block_i = Enum.find_index(disk, fn b -> hd(b) == id end)
    block = Enum.at(disk, block_i)
    block_length = length(block)

    case Enum.find_index(disk, fn b -> hd(b) == -1 and length(b) >= block_length end) do
      nil ->
        reorder_block(disk, id - 1)

      space_i when space_i > block_i ->
        reorder_block(disk, id - 1)

      space_i ->
        space = Enum.at(disk, space_i)
        space_length = length(space)

        disk
        |> List.replace_at(block_i, gen_blocks(block_length, -1))
        |> List.delete_at(space_i)
        |> then(fn disk ->
          if space_length == block_length do
            disk
          else
            List.insert_at(disk, space_i, gen_blocks(space_length - block_length, -1))
          end
        end)
        |> List.insert_at(space_i, block)
        |> reorder_block(id - 1)
    end
  end

  def reorder(disk, i, j) when i >= j, do: disk

  def reorder(disk, i, j) do
    cond do
      disk[i] != -1 ->
        reorder(disk, i + 1, j)

      disk[j] == -1 ->
        reorder(disk, i, j - 1)

      true ->
        disk
        |> Map.put(i, disk[j])
        |> Map.put(j, -1)
        |> reorder(i + 1, j - 1)
    end
  end

  def split([f], id) do
    [gen_blocks(f, id)]
  end

  def split([f, s | tl], id) do
    [gen_blocks(f, id), gen_blocks(s, -1) | split(tl, id + 1)]
  end

  def gen_blocks(n, i) do
    Stream.repeatedly(fn -> i end) |> Enum.take(n)
  end

  def input() do
    File.read!("./input.txt")
    |> String.trim()
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
  end
end
