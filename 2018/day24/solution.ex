defmodule Solution do
  defmodule Army do
    defstruct [
      :id,
      :team,
      :units,
      :hp,
      :attack,
      :attack_type,
      :weaknesses,
      :immunities,
      :initiative
    ]

    def effective_power(army) do
      army.units * army.attack
    end

    def damage(army, other) do
      cond do
        army.team == other.team -> 0
        army.attack_type in other.weaknesses -> 2
        army.attack_type in other.immunities -> 0
        true -> 1
      end
      |> then(fn scale -> effective_power(army) * scale end)
    end

    def fight(army, other) do
      damage(army, other) |> div(other.hp)
    end
  end

  def part1() do
    input()
    |> fight()
    |> Enum.map(fn {_, each} -> each.units end)
    |> Enum.sum()
  end

  def part2() do
    loop(1, input())
    |> Enum.map(fn {_, each} -> each.units end)
    |> Enum.sum()
  end

  def loop(n, armies) do
    new_armies = armies |> boost(n) |> fight()

    if win?(new_armies, "immune") do
      new_armies
    else
      loop(n + 1, armies)
    end
  end

  def boost(armies, n) do
    armies
    |> Map.new(fn {id, each} ->
      if each.team == "immune" do
        {id, %{each | attack: each.attack + n}}
      else
        {id, each}
      end
    end)
  end

  def fight(armies) do
    if win?(armies, "immune") or win?(armies, "infection") do
      armies
    else
      {armies, death_num} = select_target(armies) |> attack(armies)

      if death_num == 0 do
        armies
      else
        armies
        |> Map.filter(fn {_id, each} -> each.units > 0 end)
        |> fight()
      end
    end
  end

  def attack(targets, armies) do
    armies
    |> Enum.sort_by(fn {_id, each} -> each.initiative end, :desc)
    |> Enum.reduce({armies, 0}, fn {id, _}, {acc, death_num} ->
      self = acc[id]
      other = acc[targets[id]]

      cond do
        self.units <= 0 ->
          {acc, death_num}

        targets[id] == nil ->
          {acc, death_num}

        true ->
          num = Army.fight(self, other)

          acc = Map.put(acc, targets[id], %{other | units: other.units - num})

          {acc, num + death_num}
      end
    end)
  end

  def select_target(armies) do
    armies
    |> Enum.sort_by(fn {_id, each} -> {Army.effective_power(each), each.initiative} end, :desc)
    |> Enum.reduce({%{}, %MapSet{}}, fn {id, each}, {acc, selected} ->
      targets =
        armies
        |> Map.values()
        |> Enum.filter(fn other -> other.team != each.team and other.id not in selected end)

      case targets do
        [] ->
          {acc, selected}

        _ ->
          target =
            Enum.max_by(targets, fn other ->
              {Army.damage(each, other), Army.effective_power(other), other.initiative}
            end)

          if Army.damage(each, target) > 0 do
            {Map.put(acc, id, target.id), MapSet.put(selected, target.id)}
          else
            {acc, selected}
          end
      end
    end)
    |> elem(0)
  end

  def win?(armies, team) do
    Enum.all?(armies, fn {_, each} -> each.team == team end)
  end

  def input() do
    [t1, t2] = File.read!("input.txt") |> String.split("\n\n")

    (parse(t1) ++ parse(t2, "infection"))
    |> Enum.with_index()
    |> Map.new(fn {each, i} ->
      {i, %{each | id: i}}
    end)
  end

  def parse(s, team \\ "immune") do
    r =
      ~r/(?<units>\d+) units each with (?<hp>\d+) hit points (\((?<weaknesses>.+)\) )?with an attack that does (?<attack>\d+) (?<attack_type>[a-z]+) damage at initiative (?<initiative>\d+)/

    s
    |> String.trim()
    |> String.split("\n")
    |> Enum.drop(1)
    |> Enum.map(fn each ->
      cap = Regex.named_captures(r, each)
      weaknesses = parse_immunities_and_weaknesses(cap["weaknesses"])

      %Army{
        team: team,
        units: cap["units"] |> String.to_integer(),
        hp: cap["hp"] |> String.to_integer(),
        attack: cap["attack"] |> String.to_integer(),
        attack_type: cap["attack_type"],
        weaknesses: weaknesses["weak"] || [],
        immunities: weaknesses["immune"] || [],
        initiative: cap["initiative"] |> String.to_integer()
      }
    end)
  end

  def parse_immunities_and_weaknesses(""), do: %{}

  def parse_immunities_and_weaknesses(s) do
    s
    |> String.split("; ")
    |> Map.new(fn s ->
      [kind, s] = String.split(s, " to ")
      lst = String.split(s, ", ")
      {kind, lst}
    end)
  end
end
