# frozen_string_literal: true

require_relative '../grid/clearing'
require_relative '../factions/cats/keep'

module Root
  module Boards
    # Handles Creates graph / grid for the forest (default) board.
    # Not going to lie this might be the only one I end up creating.
    # I haven't played the expansions much so I'm not familiar with them.
    class Woodlands
      attr_accessor :clearings

      def initialize
        @clearings = WoodlandsGenerator.generate
      end

      def available_corners
        corners.select(&:with_spaces?)
      end

      def corners
        [clearings[:one], clearings[:two], clearings[:three], clearings[:four]]
      end

      # NEED ERROR CHECKING THERE'S NO WAY TO ALWAYS HAVE SLOTS FOR BUILDINGS
      def place_token(token, clearing)
        clearing.place_token(token)
      end

      def keep_in_corner?
        corners.one? do |corner|
          corner.tokens.any? do |tokens|
            tokens.type == :keep
          end
        end
      end

      private

      attr_reader :buildings
    end
  end
end
