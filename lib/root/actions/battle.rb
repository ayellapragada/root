# frozen_string_literal: true

module Root
  module Actions
    # Handles all Battle related logic!
    # Honestly more things will probably want to be moved into these.
    # For example, crafting logic and draw logic.
    # That may be a better abstraction than "Daylight()"
    class Battle
      attr_reader :clearing,
                  :attacker, :defender, :actual_defend,
                  :pieces_removed
      attr_accessor :actual_attack

      def initialize(clearing, attacker, defender)
        @clearing = clearing
        @attacker = attacker
        @defender = defender
      end

      def call
        attacker_roll, defender_roll = [dice_roll, dice_roll].sort.reverse
        attacker.player.add_to_history(
          :f_dice_roll,
          attaacker_roll: attacker_roll,
          defender_roll: defender_roll
        )
        attacker_meeples = clearing.meeples_of_type(attacker.faction_symbol)
        defender_meeples = clearing.meeples_of_type(defender.faction_symbol)

        @actual_attack = [attacker_roll, attacker_meeples.count].min
        @actual_defend = [defender_roll, defender_meeples.count].min

        @actual_attack += 1 if defender_meeples.empty?
        attacker.pre_battle(self)
        defender.pre_battle(self)
        @pieces_removed = []
        @pieces_removed << deal_damage(actual_attack, defender, attacker)
        @pieces_removed << deal_damage(actual_defend, attacker, defender)
        pieces_removed.flatten!
        attacker.post_battle(self)
        defender.post_battle(self)
      end

      def deal_damage(number, defender, attacker)
        pieces_removed = []
        until number.zero?
          meeples = clearing.meeples_of_type(defender.faction_symbol)
          cardboard_pieces =
            (clearing.buildings_of_faction(defender.faction_symbol) +
             clearing.tokens_of_faction(defender.faction_symbol))
          if !meeples.empty?
            piece = meeples.first
            clearing.meeples.delete(piece)
            defender.meeples << piece
          elsif !cardboard_pieces.empty?
            opts = cardboard_pieces
            choice = defender.player.pick_option(:f_remove_piece, opts)
            piece = opts[choice]
            plural_form = piece.piece_type.pluralize
            defender.send(plural_form) << piece
            clearing.send(plural_form).delete(piece)
            attacker.victory_points += 1
          end
          pieces_removed << piece
          number -= 1
        end
        pieces_removed
      end

      def attacker?(faction)
        attacker == faction
      end

      def dice_roll
        [0, 1, 2, 3].sample
      end
    end
  end
end
