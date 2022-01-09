defmodule Solution do
  defmodule Packet do
    defstruct [:version, :id, :value, :sub_packet, :size]
  end

  def part1() do
    input()
    |> elem(0)
    |> sum_version()
  end

  def part2() do
    input()
    |> elem(0)
    |> eval()
  end

  defp eval(p) do
    if p.id == 4 do
      p.value
    else
      packets = p.sub_packet |> Enum.map(&eval/1)

      case p.id do
        0 ->
          Enum.sum(packets)

        1 ->
          Enum.product(packets)

        2 ->
          Enum.min(packets)

        3 ->
          Enum.max(packets)

        5 ->
          [v1, v2] = packets
          if v1 > v2, do: 1, else: 0

        6 ->
          [v1, v2] = packets
          if v1 < v2, do: 1, else: 0

        7 ->
          [v1, v2] = packets
          if v1 == v2, do: 1, else: 0
      end
    end
  end

  defp sum_version(p) do
    p.version +
      Enum.reduce(p.sub_packet, 0, fn sub, acc ->
        sum_version(sub) + acc
      end)
  end

  defp parse(seq) do
    {version, seq} = parse_version(seq)
    {id, seq} = parse_id(seq)

    case id do
      4 ->
        {value, size, seq} = parse_value(seq)
        {%Packet{version: version, id: id, value: value, size: size + 6, sub_packet: []}, seq}

      _ ->
        {length_type, seq} = parse_length_type(seq)

        if length_type == 0 do
          {len, seq} = parse_length(seq)
          {sub_seq, seq} = Enum.split(seq, len)
          {sub_packet, _} = parse_with_size(sub_seq, len)
          size = Enum.reduce(sub_packet, 0, fn p, acc -> acc + p.size end) + 22
          {%Packet{version: version, id: id, sub_packet: sub_packet, size: size}, seq}
        else
          {num, seq} = parse_num(seq)
          {sub_packet, seq} = parse_with_num(seq, num)
          size = Enum.reduce(sub_packet, 0, fn p, acc -> acc + p.size end) + 18
          {%Packet{version: version, id: id, sub_packet: sub_packet, size: size}, seq}
        end
    end
  end

  defp parse_with_num(seq, n) do
    parse_with_num(seq, n, [])
  end

  defp parse_with_num(seq, 0, packets) do
    {Enum.reverse(packets), seq}
  end

  defp parse_with_num(seq, n, packets) do
    {p, seq} = parse(seq)
    parse_with_num(seq, n - 1, [p | packets])
  end

  defp parse_with_size(seq, size) do
    parse_with_size(seq, 0, size, [])
  end

  defp parse_with_size(seq, parsed, size, packets) do
    {p, seq} = parse(seq)
    parsed = parsed + p.size
    packets = [p | packets]

    if parsed == size do
      {Enum.reverse(packets), seq}
    else
      parse_with_size(seq, parsed, size, packets)
    end
  end

  defp parse_length(seq) do
    {len, rest} = Enum.split(seq, 15)
    {list_to_int(len), rest}
  end

  defp parse_num(seq) do
    {num, rest} = Enum.split(seq, 11)
    {list_to_int(num), rest}
  end

  defp parse_version(seq) do
    {version, rest} = Enum.split(seq, 3)
    {list_to_int(version), rest}
  end

  defp parse_id(seq) do
    {id, rest} = Enum.split(seq, 3)
    {list_to_int(id), rest}
  end

  defp parse_value(seq) do
    parse_value(seq, "", 0)
  end

  defp parse_value(seq, value, size) do
    {bits, seq} = Enum.split(seq, 5)
    {head, bits} = Enum.split(bits, 1)

    value = value <> Enum.join(bits)
    size = size + 5

    if head == ["1"] do
      parse_value(seq, value, size)
    else
      {String.to_integer(value, 2), size, seq}
    end
  end

  defp parse_length_type(seq) do
    {length_type, rest} = Enum.split(seq, 1)
    {list_to_int(length_type), rest}
  end

  defp list_to_int(s) do
    s |> Enum.join() |> String.to_integer(2)
  end

  defp input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&to_binary/1)
    |> Enum.to_list()
    |> List.first()
    |> parse()
  end

  defp to_binary(hex) do
    dt = %{
      "0" => "0000",
      "1" => "0001",
      "2" => "0010",
      "3" => "0011",
      "4" => "0100",
      "5" => "0101",
      "6" => "0110",
      "7" => "0111",
      "8" => "1000",
      "9" => "1001",
      "A" => "1010",
      "B" => "1011",
      "C" => "1100",
      "D" => "1101",
      "E" => "1110",
      "F" => "1111"
    }

    hex |> String.graphemes() |> Enum.flat_map(fn c -> Map.get(dt, c) |> String.graphemes() end)
  end
end
