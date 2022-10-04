defmodule Solution do
  defmodule Cart do
    @up [0, -1]
    @down [0, 1]
    @left [-1, 0]
    @right [1, 0]
    @slash %{@up => @right, @down => @left, @left => @down, @right => @up}
    @backward_slash %{@up => @left, @down => @right, @left => @up, @right => @down}
    @turn_left %{@up => @left, @down => @right, @left => @down, @right => @up}
    @turn_right %{@up => @right, @down => @left, @left => @up, @right => @down}

    defstruct [:position, :direction, :turns, :sentinel]

    def sentinel() do
      %Cart{sentinel: true}
    end

    def new(position, direction) do
      %Cart{position: position, direction: direction, turns: 0}
    end

    def move(cart, grid) do
      pos = Enum.zip(cart.position, cart.direction) |> Enum.map(fn {p, d} -> p + d end)
      cart = %{cart | position: pos}

      case grid[cart.position] do
        "\\" ->
          d = @backward_slash[cart.direction]
          %{cart | direction: d}

        "/" ->
          d = @slash[cart.direction]
          %{cart | direction: d}

        "+" ->
          d =
            case cart.turns do
              0 -> @turn_left[cart.direction]
              1 -> cart.direction
              2 -> @turn_right[cart.direction]
            end

          %{cart | direction: d, turns: rem(cart.turns + 1, 3)}

        _ ->
          cart
      end
    end

    def hit?(cart, other) do
      cart.position == other.position
    end
  end

  def part1() do
    run()
  end

  def part2() do
    run(true)
  end

  def run(last? \\ false) do
    input()
    |> then(fn {grid, carts} ->
      carts
      |> List.insert_at(-1, Cart.sentinel())
      |> tick(grid, last?)
    end)
    |> then(fn [y, x] -> "#{y},#{x}" end)
  end

  def tick([c | cs], grid, last?) do
    cond do
      c.sentinel && length(cs) == 1 ->
        cs |> hd() |> Map.get(:position)

      c.sentinel ->
        cs
        |> Enum.sort_by(fn c -> c.position |> Enum.reverse() end)
        |> List.insert_at(-1, Cart.sentinel())
        |> tick(grid, last?)

      true ->
        c = Cart.move(c, grid)
        ndx = Enum.find_index(cs, &Cart.hit?(c, &1))

        cond do
          ndx != nil && last? ->
            cs
            |> List.delete_at(ndx)
            |> tick(grid, last?)

          ndx != nil ->
            c.position

          true ->
            tick(cs ++ [c], grid, last?)
        end
    end
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.with_index()
    |> Enum.reduce({%{}, []}, fn {row, j}, {grid, carts} ->
      row
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce({grid, carts}, fn {c, i}, {grid, carts} ->
        carts =
          if c in ["<", ">", "^", "v"] do
            [Cart.new([i, j], direction(c)) | carts]
          else
            carts
          end

        {Map.put(grid, [i, j], c), carts}
      end)
    end)
  end

  def direction(d) do
    case d do
      "<" -> [-1, 0]
      "v" -> [0, 1]
      ">" -> [1, 0]
      "^" -> [0, -1]
    end
  end
end
