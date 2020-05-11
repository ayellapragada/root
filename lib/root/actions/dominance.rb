# frozen_string_literal: true

module Root
  module Actions
    # Handles all Dominance related logic
    class Dominance
      attr_reader :faction

      def initialize(faction)
        @faction = faction
      end

      def check
        raise Errors::WinConditionReached.new(faction, :dominance) if dominance?
      end

      private

      def dominance?
        suit = faction.victory_points

        if %i[fox mouse rabbit].include?(suit)
          suit_dominance?(suit)
        elsif suit == :bird
          bird_dominance?
        end
      end

      def bird_dominance?
        faction.board.corners.any? do |cl|
          opposite_cl = faction.board.clearing_across(cl)
          faction.rule?(cl) && faction.rule?(opposite_cl)
        end
      end

      def suit_dominance?(suit)
        ruled_cl = faction.board.clearings_of_suit(suit).count do |cl|
          faction.rule?(cl)
        end
        ruled_cl >= 3
      end
    end
  end
end
