defmodule Solution do
  defmodule Unit do
    defstruct [:id, :team, :hp, :position, :ap]

    def new(team, position, ap \\ 3) do
      %Unit{id: new_id(), team: team, hp: 200, position: position, ap: ap}
    end

    defp new_id() do
      for _ <- 1..5, into: "", do: <<Enum.random('0123456789abcdef')>>
    end
  end

  defmodule Game do
    use GenServer

    def new() do
      GenServer.start_link(__MODULE__, {0, %{}, MapSet.new(), false}, name: __MODULE__)
    end

    def loop(must_win? \\ false) do
      cond do
        must_win? && loss?() ->
          :loss

        stop?() ->
          score()

        true ->
          run()
          loop(must_win?)
      end
    end

    def run() do
      units()
      |> Enum.sort_by(fn {_, u} -> u.position end)
      |> Enum.reduce_while(true, fn {_, u}, done? ->
        if not stop?() do
          if dead?(u) do
            {:cont, done?}
          else
            u |> try_move() |> try_attack()

            {:cont, done?}
          end
        else
          {:halt, false}
        end
      end)
      |> then(fn done? ->
        done? && update_round()
      end)
    end

    def try_move(unit) do
      obstacles = find_obstacles(unit)

      enemy_positions =
        unit
        |> find_enemy_positions()
        |> adjacents()
        |> MapSet.difference(obstacles)

      if unit.position in enemy_positions do
        unit
      else
        paths = shortest_paths(unit.position, enemy_positions, obstacles)

        if paths == [] do
          unit
        else
          target_pos = paths |> Enum.map(&List.last/1) |> Enum.min()
          paths = shortest_paths(unit.position, [target_pos], obstacles)
          next_pos = paths |> Enum.map(fn p -> p |> tl() |> hd() end) |> Enum.min()
          update_unit_position(unit, next_pos)
        end
      end
    end

    def try_attack(unit) do
      enemy =
        units()
        |> Enum.filter(fn {_, u} ->
          u.team != unit.team && manhattan_distance(u.position, unit.position) == 1
        end)
        |> Enum.map(fn {_, u} -> {u.hp, u.position, u} end)
        |> Enum.min(fn -> {nil, nil, nil} end)
        |> elem(2)

      if enemy != nil do
        attack(unit, enemy)
      end
    end

    def manhattan_distance({x1, y1}, {x2, y2}) do
      abs(x1 - x2) + abs(y1 - y2)
    end

    def find_obstacles(unit) do
      find_team_positions(unit)
      |> MapSet.new()
      |> MapSet.union(walls())
    end

    def find_enemy_positions(unit) do
      units()
      |> Enum.filter(fn {_, u} -> u.team != unit.team end)
      |> Enum.map(fn {_, u} -> u.position end)
    end

    def find_team_positions(unit) do
      units()
      |> Enum.filter(fn {_, u} -> u.team == unit.team && u.id != unit.id end)
      |> Enum.map(fn {_, u} -> u.position end)
    end

    def adjacent({i, j}) do
      [{i - 1, j}, {i, j - 1}, {i, j + 1}, {i + 1, j}]
    end

    def adjacents(positions) do
      positions
      |> Enum.reduce(MapSet.new(), fn p, acc ->
        p
        |> adjacent()
        |> MapSet.new()
        |> MapSet.union(acc)
      end)
    end

    def shortest_paths(source, targets, visited) do
      shortest_paths(:queue.from_list([{0, [source]}]), targets, visited, [])
    end

    def shortest_paths(q, targets, visited, paths) do
      if :queue.is_empty(q) do
        paths
      else
        {distance, path} = :queue.head(q)
        q = :queue.tail(q)
        pos = List.last(path)

        cond do
          length(paths) > 0 && length(path) > length(hd(paths)) ->
            paths

          pos in targets ->
            shortest_paths(q, targets, visited, [path | paths])

          pos in visited ->
            shortest_paths(q, targets, visited, paths)

          true ->
            visited = MapSet.put(visited, pos)

            pos
            |> adjacent()
            |> Enum.filter(fn p -> p not in visited end)
            |> Enum.reduce(q, fn pos, q ->
              :queue.snoc(q, {distance + 1, path ++ [pos]})
            end)
            |> shortest_paths(targets, visited, paths)
        end
      end
    end

    # ------ client ------
    def reset(units, walls) do
      GenServer.call(__MODULE__, {:reset, units, walls})
    end

    def stop?() do
      GenServer.call(__MODULE__, :stop?)
    end

    def loss?() do
      GenServer.call(__MODULE__, :loss?)
    end

    def dead?(unit) do
      GenServer.call(__MODULE__, {:dead?, unit})
    end

    def update_round() do
      GenServer.call(__MODULE__, :update_round)
    end

    def score() do
      GenServer.call(__MODULE__, :score)
    end

    def units() do
      GenServer.call(__MODULE__, :units)
    end

    def walls() do
      GenServer.call(__MODULE__, :walls)
    end

    def update_unit_position(unit, pos) do
      GenServer.call(__MODULE__, {:update_unit_position, unit, pos})
    end

    def attack(unit, enemy) do
      GenServer.call(__MODULE__, {:attack, unit, enemy})
    end

    # ------ server ------
    defmodule State do
      defstruct rounds: 0, units: %{}, walls: MapSet.new(), loss?: false
    end

    def init(_) do
      {:ok, %State{}}
    end

    def handle_call({:reset, units, walls}, _from, _) do
      {:reply, :ok, %State{units: units, walls: walls}}
    end

    def handle_call(:loss?, _from, state) do
      {:reply, state.loss?, state}
    end

    def handle_call(:units, _from, state) do
      {:reply, state.units, state}
    end

    def handle_call({:dead?, unit}, _from, state) do
      {:reply, state.units[unit.id] == nil, state}
    end

    def handle_call(:update_round, _from, state) do
      state = Map.update!(state, :rounds, &(&1 + 1))
      {:reply, state.rounds, state}
    end

    def handle_call({:update_unit_position, unit, position}, _from, state) do
      unit = %{unit | position: position}
      state = %{state | units: Map.put(state.units, unit.id, unit)}
      {:reply, unit, state}
    end

    def handle_call({:attack, unit, enemy}, _from, state) do
      enemy = %{enemy | hp: enemy.hp - unit.ap}

      if enemy.hp <= 0 do
        state = %{state | units: Map.delete(state.units, enemy.id), loss?: enemy.team == "E"}
        {:reply, enemy, state}
      else
        state = %{state | units: Map.put(state.units, enemy.id, enemy)}
        {:reply, enemy, state}
      end
    end

    def handle_call(:walls, _from, state) do
      {:reply, state.walls, state}
    end

    def handle_call(:stop?, _from, state) do
      r =
        state.units
        |> Enum.map(fn {_, u} -> u.team end)
        |> Enum.uniq()

      {:reply, length(r) == 1, state}
    end

    def handle_call(:score, _from, state) do
      sc =
        state.units
        |> Enum.reduce(0, fn {_, u}, acc -> u.hp + acc end)
        |> then(&(&1 * state.rounds))

      {:reply, sc, state}
    end
  end

  def part1() do
    Game.new()

    {units, walls} = input() |> prepare()

    Game.reset(units, walls)

    Game.loop()
  end

  def part2(ap \\ 4) do
    Game.new()

    {units, walls} = input() |> prepare(ap)

    Game.reset(units, walls)

    case Game.loop(true) do
      :loss -> part2(ap + 1)
      score -> score
    end
  end

  def prepare(grid, elf_ap \\ 3) do
    grid
    |> Stream.with_index()
    |> Enum.reduce({%{}, MapSet.new()}, fn {row, i}, {units, walls} ->
      row
      |> Enum.with_index()
      |> Enum.reduce({units, walls}, fn {c, j}, {units, walls} ->
        pos = {i, j}

        cond do
          c == "#" ->
            {units, MapSet.put(walls, pos)}

          c == "G" ->
            unit = Unit.new(c, pos)
            {Map.put(units, unit.id, unit), walls}

          c == "E" ->
            unit = Unit.new(c, pos, elf_ap)
            {Map.put(units, unit.id, unit), walls}

          true ->
            {units, walls}
        end
      end)
    end)
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.graphemes/1)
  end
end
