defmodule Solution do
  defmodule GameState do
    defmodule Spell do
      defstruct [:name, :cost, :damage, :armor, :heal, :mana, :turns]

      def all() do
        [
          %Spell{name: "Missile", cost: 53, damage: 4, armor: 0, heal: 0, mana: 0, turns: 1},
          %Spell{name: "Drain", cost: 73, damage: 2, armor: 0, heal: 2, mana: 0, turns: 1},
          %Spell{name: "Shield", cost: 113, damage: 0, armor: 7, heal: 0, mana: 0, turns: 6},
          %Spell{name: "Poison", cost: 173, damage: 3, armor: 0, heal: 0, mana: 0, turns: 6},
          %Spell{name: "Recharge", cost: 229, damage: 0, armor: 0, heal: 0, mana: 101, turns: 5}
        ]
      end
    end

    defstruct [
      :player_hp,
      :player_mp,
      :player_armor,
      :boss_hp,
      :boss_damage,
      :mana_spent,
      :activeEffects
    ]

    def has_end?(state) do
      state.player_hp <= 0 || state.boss_hp <= 0
    end

    def spells(state) do
      if GameState.has_end?(state) do
        []
      else
        Spell.all()
        |> Enum.filter(fn spell ->
          active = state.activeEffects |> Enum.find(fn effect -> effect.name == spell.name end)
          state.player_mp >= spell.cost && (active == nil || active.turns == 1)
        end)
        |> Enum.map(fn spell -> {state, spell} end)
      end
    end

    def enact_effect(state) do
      if has_end?(state) do
        state
      else
        %GameState{
          state
          | player_mp: state.player_mp + sumProp(state.activeEffects, :mana),
            boss_hp: state.boss_hp - sumProp(state.activeEffects, :damage),
            player_armor: sumProp(state.activeEffects, :armor),
            activeEffects:
              state.activeEffects
              |> Enum.map(fn effect -> Map.update!(effect, :turns, &(&1 - 1)) end)
              |> Enum.filter(fn effect -> effect.turns > 0 end)
        }
      end
    end

    def player_turn(state, spell) do
      if has_end?(state) do
        state
      else
        if spell.turns > 1 do
          %GameState{
            state
            | player_mp: state.player_mp - spell.cost,
              mana_spent: state.mana_spent + spell.cost,
              activeEffects: [spell | state.activeEffects]
          }
        else
          %GameState{
            state
            | player_hp: state.player_hp + spell.heal,
              player_mp: state.player_mp - spell.cost,
              boss_hp: state.boss_hp - spell.damage,
              mana_spent: state.mana_spent + spell.cost
          }
        end
      end
    end

    def boss_turn(state) do
      if has_end?(state) do
        state
      else
        %GameState{
          state
          | player_hp: state.player_hp - max(state.boss_damage - state.player_armor, 1)
        }
      end
    end

    def turn(state, spell) do
      state
      |> enact_effect()
      |> player_turn(spell)
      |> enact_effect()
      |> boss_turn()
    end

    def win?(state) do
      has_end?(state) && state.player_hp > 0
    end

    def sumProp(lst, prop) do
      Enum.reduce(lst, 0, fn e, acc -> acc + Map.get(e, prop) end)
    end

    def new(player_hp, player_mp, boss_hp, boss_damage) do
      %GameState{
        player_hp: player_hp,
        player_mp: player_mp,
        player_armor: 0,
        boss_hp: boss_hp,
        boss_damage: boss_damage,
        mana_spent: 0,
        activeEffects: []
      }
    end
  end

  def game_loop(q) do
    {state, spell} = :queue.head(q)
    q = :queue.drop(q)

    state = GameState.turn(state, spell)

    cond do
      GameState.win?(state) ->
        state.mana_spent

      GameState.has_end?(state) ->
        game_loop(q)

      true ->
        GameState.spells(state)
        |> Enum.reduce(q, &:queue.in/2)
        |> game_loop()
    end
  end

  def part1() do
    GameState.new(50, 500, 71, 10)
    |> GameState.spells()
    |> :queue.from_list()
    |> game_loop()
  end

  def part2() do
    GameState.new(50, 500, 71, 11)
    |> GameState.spells()
    |> :queue.from_list()
    |> game_loop()
  end
end
