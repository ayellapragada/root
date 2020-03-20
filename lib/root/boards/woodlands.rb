# frozen_string_literal: true

require_relative '../grid/clearing'
require_relative '../factions/pieces/cat/keep'

module Root
  module Boards
    # Handles Creates graph / grid for the forest (default) board.
    # Not going to lie this might be the only one I end up creating.
    # I haven't played the expansions much so I'm not familiar with them.
    class Woodlands
      BUILDINGS_MAP = {
        keep: Root::Factions::Pieces::Cat::Keep
      }.freeze

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
      def create_building(type, clearing)
        building = BUILDINGS_MAP[type].new
        clearing.create_building(building)
      end

      def keep_in_corner?
        corners.one? { |corner| corner.buildings.any?(&:is_keep?) }
      end

      private

      attr_reader :buildings
    end
  end
end
