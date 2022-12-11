defmodule Solution do
  use Agent

  defmodule Node do
    defstruct [:id, :type, :name, :size, :parent, :children]

    def new(type, name, size, parent, children) do
      id = if name == "/", do: "/", else: new_id()
      %Node{id: id, type: type, name: name, size: size, parent: parent, children: children}
    end

    def push(node, name) do
      %{node | children: node.children ++ [name]}
    end

    defp new_id() do
      for _ <- 1..5, into: "", do: <<Enum.random('0123456789abcdef')>>
    end
  end

  def part1() do
    start()

    find("/", 0, fn acc, node ->
      acc + if node.size <= 100_000, do: node.size, else: 0
    end)
  end

  def part2() do
    start()

    avail = 70_000_000 - get("/").size
    required_space = 30_000_000 - avail

    find("/", [], fn lst, node ->
      if node.size >= required_space, do: [node.size | lst], else: lst
    end)
    |> Enum.min()
  end

  def find(id, acc, f) do
    node = get(id)

    if node.type == :file do
      acc
    else
      node.children
      |> Enum.reduce(acc, fn c, acc -> find(c, acc, f) end)
      |> f.(node)
    end
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Enum.to_list()
  end

  def pack([]), do: nil

  def pack([c | cs]) do
    if c == "$ ls" do
      current = pwd()
      {children, cs} = Enum.split_while(cs, fn s -> not String.starts_with?(s, "$") end)

      children
      |> Enum.each(fn child ->
        case String.split(child, " ") do
          ["dir", name] ->
            Node.new(:dir, name, 0, current.id, [])

          [size, name] ->
            Node.new(:file, name, String.to_integer(size), current.id, [])
        end
        |> add()
      end)

      pack(cs)
    else
      c |> String.replace("$ cd ", "") |> cd()
      pack(cs)
    end
  end

  def start() do
    init = {"/", %{"/" => Node.new(:dir, "/", 0, "/", [])}}
    Agent.start_link(fn -> init end, name: __MODULE__)
    Agent.update(__MODULE__, fn _ -> init end)
    input() |> pack()
    du("/")
  end

  def du(id) do
    node = get(id)

    if node.type == :file do
      node.size
    else
      node.children
      |> Enum.reduce(node.size, fn c, acc -> du(c) + acc end)
      |> tap(fn size -> %{node | size: size} |> set() end)
    end
  end

  def get(id) do
    Agent.get(__MODULE__, fn {_current_id, dir} -> dir[id] end)
  end

  def set(node) do
    Agent.update(__MODULE__, fn {current_id, dir} ->
      {current_id, Map.put(dir, node.id, node)}
    end)
  end

  def cd(name) do
    Agent.update(__MODULE__, fn {current_id, dir} ->
      current_id =
        case name do
          ".." -> dir[current_id].parent
          "/" -> "/"
          name -> dir[current_id].children |> Enum.find(fn c -> dir[c].name == name end)
        end

      {current_id, dir}
    end)
  end

  def pwd() do
    Agent.get(__MODULE__, fn {current_id, dir} -> dir[current_id] end)
  end

  def add(node) do
    Agent.update(__MODULE__, fn {current_id, dir} ->
      current_node = dir[current_id] |> Node.push(node.id)
      dir = Map.put(dir, node.id, node) |> Map.put(current_id, current_node)
      {current_id, dir}
    end)
  end
end
