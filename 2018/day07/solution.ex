defmodule Solution do
  def part1() do
    {tasks, vs, ds} = gen_tasks()
    run(tasks, vs, ds, "")
  end

  def part2() do
    {tasks, vs, ds} = gen_tasks()
    run_parallel(tasks, :gb_sets.empty(), vs, ds, 0)
  end

  def gen_tasks() do
    {vs, ds} =
      input()
      |> Enum.reduce({%{}, %{}}, fn {from, to}, {v, d} ->
        {Map.update(v, from, [to], &[to | &1]), Map.update(d, to, 1, &(&1 + 1))}
      end)

    tasks =
      vs
      |> Map.keys()
      |> Enum.filter(fn k -> Map.get(ds, k, 0) == 0 end)
      |> Enum.sort()
      |> :gb_sets.from_list()

    {tasks, vs, ds}
  end

  def run(tasks, vs, ds, res) do
    if :gb_sets.is_empty(tasks) do
      res
    else
      {v, tasks} = :gb_sets.take_smallest(tasks)
      res = res <> v

      {tasks, ds} = add_tasks(tasks, Map.get(vs, v, []), ds)

      run(tasks, vs, ds, res)
    end
  end

  def add_tasks(tasks, vs, ds) do
    vs
    |> Enum.reduce({tasks, ds}, fn u, {tasks, ds} ->
      ds = Map.update!(ds, u, &(&1 - 1))

      if ds[u] == 0 do
        {:gb_sets.add(u, tasks), ds}
      else
        {tasks, ds}
      end
    end)
  end

  def run_parallel(tasks, workers, vs, ds, t) do
    {tasks, workers} = assign_jobs(tasks, workers, t)

    if :gb_sets.is_empty(tasks) and :gb_sets.is_empty(workers) do
      t
    else
      {{t, v}, workers} = :gb_sets.take_smallest(workers)

      {tasks, ds} = add_tasks(tasks, Map.get(vs, v, []), ds)

      run_parallel(tasks, workers, vs, ds, t)
    end
  end

  def assign_jobs(tasks, workers, t) do
    if :gb_sets.size(workers) < 5 and not :gb_sets.is_empty(tasks) do
      {v, tasks} = :gb_sets.take_smallest(tasks)
      workers = :gb_sets.add({t + :binary.first(v) - ?A + 61, v}, workers)
      assign_jobs(tasks, workers, t)
    else
      {tasks, workers}
    end
  end

  def input() do
    File.stream!("./input.txt")
    |> Stream.map(fn s ->
      [_, from, _, _, _, _, _, to | _] = String.split(s, " ")
      {from, to}
    end)
  end
end
