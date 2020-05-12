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

        armorers

        add_extra_hits

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
        true
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

      def ambush
        attacker_immune = attacker.improvements_include?(:scouting_party)
        text = attacker_immune ? '. Attacker ignores ambush' : ''
        ambush_info = {
          faction: attacker.faction_symbol,
          clearing: priority,
          text: text
        }
        foil_info = { clearing: priority }

        def_ambush_opts = defender.ambush_opts(clearing)

        def_card =
          defender
          .player
          .choose(:f_ambush, def_ambush_opts, info: ambush_info) do |card|
            defender.discard_card(card)
            card
          end

        return false if attacker_immune || !def_card

        foil_opts = attacker.ambush_opts(clearing)
        defender.player.add_to_history(:f_ambush, ambush_info)
        attacker
          .player
          .choose(:f_foil_ambush, foil_opts, info: foil_info) do |card|
          attacker.discard_card(card)
          attacker.player.add_to_history(:f_foil_ambush, foil_info)
          return false
        end

        pieces_removed << deal_damage(2, attacker, defender)
      end

      def armorers
        use_armorer(defender)
        use_armorer(attacker)
      end

      def add_extra_hits
        self.actual_attack += 1 if defender.defenseless?(clearing)
        use_sappers(defender)
        use_brutal_tactics(attacker)
      end

      def use_armorer(faction)
        hits = attacker?(faction) ? actual_defend : self.actual_attack
        info = { hits: hits }

        opts = faction.improvements_options(:armorers)
        faction.player.choose(:f_armorers, opts, info: info) do |improvement|
          faction.discard_improvement(improvement)
          faction.player.add_to_history(:f_armorers, info)
          attacker?(faction) ? self.actual_defend = 0 : self.actual_attack = 0
        end
      end

      def use_sappers(faction)
        info = { hits: actual_defend }

        opts = faction.improvements_options(:sappers)
        faction.player.choose(:f_sappers, opts, info: info) do |improvement|
          faction.discard_improvement(improvement)
          faction.player.add_to_history(:f_sappers)
          self.actual_defend += 1
        end
      end

      def use_brutal_tactics(faction)
        info = { hits: actual_attack }

        opts = faction.improvements_options(:brutal_tactics)
        faction.player.choose(:f_brutal_tactics, opts, info: info) do
          faction.player.add_to_history(:f_brutal_tactics)
          self.actual_attack += 1
          defender.victory_points += 1
        end
      end

      def priority
        clearing.priority
      end
    end
  end
end
