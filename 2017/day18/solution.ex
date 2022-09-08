defmodule Solution do
  defmodule Program do
    defstruct rs: %{},
              pc: 0,
              ins: %{},
              input: :queue.new(),
              output: :queue.new(),
              stop?: false,
              send_times: 0

    def new(ins, p \\ 0) do
      %Program{rs: Map.put(%{}, "p", p), ins: ins}
    end

    def get(prog, x) do
      if Regex.match?(~r/-?\d+/, x) do
        String.to_integer(x)
      else
        Map.get(prog.rs, x, 0)
      end
    end

    def exec(prog, correct? \\ false) do
      case prog.ins[prog.pc] do
        nil ->
          %{prog | stop?: true}

        ["snd", x] ->
          if correct? do
            %{
              prog
              | pc: prog.pc + 1,
                output: :queue.in(get(prog, x), prog.output),
                send_times: prog.send_times + 1
            }
          else
            %{
              prog
              | pc: prog.pc + 1,
                input: prog |> get(x) |> :queue.in(prog.input)
            }
          end

        ["set", x, y] ->
          %{
            prog
            | pc: prog.pc + 1,
              rs: Map.put(prog.rs, x, get(prog, y))
          }

        ["add", x, y] ->
          y = get(prog, y)

          %{
            prog
            | pc: prog.pc + 1,
              rs: Map.update(prog.rs, x, y, &(&1 + y))
          }

        ["mul", x, y] ->
          y = get(prog, y)

          %{
            prog
            | pc: prog.pc + 1,
              rs: Map.update(prog.rs, x, 0, &(&1 * y))
          }

        ["mod", x, y] ->
          y = get(prog, y)

          %{
            prog
            | pc: prog.pc + 1,
              rs: Map.update(prog.rs, x, 0, &rem(&1, y))
          }

        ["rcv", x] ->
          if correct? do
            if :queue.is_empty(prog.input) do
              %{prog | stop?: true}
            else
              v = :queue.head(prog.input)

              %{
                prog
                | pc: prog.pc + 1,
                  rs: Map.put(prog.rs, x, v),
                  input: :queue.tail(prog.input)
              }
            end
          else
            if get(prog, x) > 0 do
              %{prog | stop?: true}
            else
              %{prog | pc: prog.pc + 1}
            end
          end

        ["jgz", x, y] ->
          pc = if get(prog, x) > 0, do: prog.pc + get(prog, y), else: prog.pc + 1
          %{prog | pc: pc}
      end
    end

    def run(prog, correct? \\ false) do
      if prog.stop? do
        prog
      else
        prog |> exec(correct?) |> run(correct?)
      end
    end

    def read(prog, q) do
      if :queue.is_empty(q) do
        prog
      else
        %{prog | input: q, stop?: false}
      end
    end

    def consume(prog) do
      %{prog | output: :queue.new()}
    end
  end

  def part1() do
    input()
    |> Program.new()
    |> Program.run()
    |> Map.get(:input)
    |> :queue.daeh()
  end

  def part2() do
    ins = input()
    p0 = Program.new(ins, 0)
    p1 = Program.new(ins, 1)
    concurrent(p0, p1)
  end

  def concurrent(p0, p1) do
    if p0.stop? && p1.stop? do
      p1.send_times
    else
      p0 = Program.run(p0, true)
      p1 = Program.run(p1, true)
      p0 = Program.read(p0, p1.output)
      p1 = Program.read(p1, p0.output)
      concurrent(Program.consume(p0), Program.consume(p1))
    end
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.split/1)
    |> Enum.to_list()
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {c, i}, acc ->
      Map.put(acc, i, c)
    end)
  end
end
