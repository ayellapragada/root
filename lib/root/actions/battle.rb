# frozen_string_literal: true

module Root
  module Actions
    # Handles all Battle related logic!
    # Honestly more things will probably want to be moved into these.
    # For example, crafting logic and draw logic.
    # That may be a better abstraction than "Daylight()"
    class Battle
      attr_reader :clearing, :type,
                  :attacker, :defender, :ally,
                  :pieces_removed
      attr_accessor :actual_attack, :actual_defend

      def initialize(clearing, attacker, defender, ally: nil)
        @clearing = clearing
        @attacker = attacker
        @defender = defender
        @pieces_removed = []
        @ally = ally
      end

      def call
        @type = :battle
        ambush
        return if attacker.max_hit(clearing, ally: @ally).zero?

        atk, def_roll = assign_dice_rolls

        self.actual_attack = [atk, attacker.max_hit(clearing, ally: @ally)].min
        self.actual_defend = [def_roll, defender.max_hit(clearing)].min

        self.actual_attack += 1 if defender.defenseless?(clearing)

        commence_battle
      end

      def strike
        @type = :strike
        self.actual_attack = 1
        self.actual_defend = 0

        commence_battle
      end

      def attacker?(faction)
        [attacker, attacker.faction_symbol].include?(faction)
      end

      def ally?(faction)
        [ally, ally&.faction_symbol].include?(faction)
      end

      def other_faction(faction)
        attacker == faction ? defender : attacker
      end

      def removed?(type)
        pieces_removed.map(&:type).include?(type)
      end

      def removed_of_other_type(fac)
        pieces_removed
          .reject { |p| p.faction == fac }
      end

      def removed_of_type(fac)
        pieces_removed
          .select { |p| p.faction == fac }
      end

      private

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
          clearing: priority
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
          clearing: priority
        )
      end

      def deal_damage(number, defender, attacker)
        pieces_removed = []
        number.times do
          pieces_removed << defender.take_damage(clearing, ally: @ally)
        end

        pieces_removed.compact!

        pieces_removed.count(&:points_for_removing?).times do
          attacker.victory_points += 1
        end

        pieces_removed
      end

      def dice_roll
        [0, 1, 2, 3].sample
      end

      private

      def ambush
        ambush_info = { faction: attacker.faction_symbol, clearing: priority }
        foil_info = { clearing: priority }
        def_card =
          defender.player.choose(:f_ambush, defender.ambush_opts(clearing), info: ambush_info) { |c| c }
        return unless def_card

        defender.player.add_to_history(:f_ambush, ambush_info)
        attacker.player.choose(:f_foil_ambush, attacker.ambush_opts(clearing), info: foil_info) do
          attacker.player.add_to_history(:f_foil_ambush, foil_info)
          return
        end

        pieces_removed << deal_damage(2, attacker, defender)
      end

      def priority
        clearing.priority
      end
    end
  end
end
