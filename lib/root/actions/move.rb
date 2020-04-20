# frozen_string_literal: true

module Root
  module Actions
    # Handles all Move related logic
    # Can be passed around so factions can do movement related checks
    class Move
      attr_reader :from_clearing, :to_clearing, :num_to_move, :faction, :players

      def initialize(from_clearing, to_clearing, num_to_move, faction, players)
        @from_clearing = from_clearing
        @to_clearing = to_clearing
        @num_to_move = num_to_move
        @faction = faction
        @players = players
      end

      def call
        move_meeples
        add_history
      end

      def move_meeples
        num_to_move.times do
          piece = from_clearing.meeples_of_type(faction.faction_symbol).first
          from_clearing.meeples.delete(piece)
          to_clearing.meeples << piece
        end
      end

      def add_history
        faction.player.add_to_history(
          :f_move_number,
          num: num_to_move,
          from: from_clearing.priority,
          to: to_clearing.priority
        )
      end
    end
  end
end
