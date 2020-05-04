# frozen_string_literal: true

module Root
  module Actions
    # Handles all Battle related logic!
    # Honestly more things will probably want to be moved into these.
    # For example, crafting logic and draw logic.
    # That may be a better abstraction than "Daylight()"
    class Battle
      attr_reader :clearing,
                  :attacker, :defender,
                  :pieces_removed
      attr_accessor :actual_attack, :actual_defend

      def initialize(clearing, attacker, defender)
        @clearing = clearing
        @attacker = attacker
        @defender = defender
        @pieces_removed = []
      end

      def call
        attacker_roll, defender_roll = assign_dice_rolls

        self.actual_attack = [attacker_roll, attacker.max_hit(clearing)].min
        self.actual_defend = [defender_roll, defender.max_hit(clearing)].min

        self.actual_attack += 1 if defender.defenseless?(clearing)

        commence_battle
      end

      def assign_dice_rolls
        attacker_roll, defender_roll = [dice_roll, dice_roll].sort.reverse
        # guerilla warfare lmfao
        # it needs to be before adding points so :spinshrug:
        if defender.faction_symbol == :mice
          attacker_roll, defender_roll = defender_roll, attacker_roll
        end

        attacker.player.add_to_history(
          :f_dice_roll,
          attaacker_roll: attacker_roll,
          defender_roll: defender_roll,
          clearing: clearing.priority
        )
        [attacker_roll, defender_roll]
      end

      def commence_battle
        battle_with_hooks do
          pieces_removed << deal_damage(actual_attack, defender, attacker)
          pieces_removed << deal_damage(actual_defend, attacker, defender)
          pieces_removed.flatten!
        end

        add_history
      end

      def battle_with_hooks
        attacker.pre_battle(self)
        defender.pre_battle(self)
        yield
        attacker.post_battle(self)
        defender.post_battle(self)
      end

      def add_history
        attacker.player.add_to_history(
          :f_who_to_battle,
          damage_done: actual_attack,
          damage_taken: actual_defend,
          other_faction: defender.faction_symbol,
          clearing: clearing.priority
        )
      end

      def deal_damage(number, defender, attacker)
        pieces_removed = []
        number.times { pieces_removed << defender.take_damage(clearing) }

        pieces_removed.flatten!

        pieces_removed.count(&:points_for_removing?).times do
          attacker.victory_points += 1
        end

        pieces_removed
      end

      def attacker?(faction)
        attacker == faction
      end

      def other_faction(faction)
        attacker == faction ? defender : attacker
      end

      def dice_roll
        [0, 1, 2, 3].sample
      end

      def removed?(type)
        pieces_removed.map(&:type).include?(type)
      end
    end
  end
end
