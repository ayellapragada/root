# frozen_string_literal: true

require_relative '../grid/clearing'
require_relative '../factions/cats/keep'

module Root
  module Boards
    # Handles Creates graph / grid for the forest (default) board.
    # Not going to lie this might be the only one I end up creating.
    # I haven't played the expansions much so I'm not familiar with them.
    class Base
      attr_reader :all_clearings, :items

      DIAGANOLS = { 1 => :three, 2 => :four, 3 => :one, 4 => :two }.freeze

      def initialize(generator: WoodlandsGenerator, items: nil)
        @all_clearings = generator.generate
        @items = items || ItemsGenerator.generate
      end

      #:nocov:
      def test_render
        Root::Display::WoodlandsMap.new(self).display
      end
      #:nocov:

      def available_corners
        corners.select(&:with_spaces?)
      end

      def corners
        [clearings[:one], clearings[:two], clearings[:three], clearings[:four]]
      end

      def clearings
        all_clearings.select { |key, _| all_clearings[key].clearing? }
      end

      def forests
        all_clearings.select { |key, _| all_clearings[key].forest? }
      end

      def place_token(token, clearing)
        clearing.place_token(token)
      end

      def create_building(building, clearing)
        clearing.create_building(building)
      end

      def place_meeple(meeple, clearing)
        clearing.place_meeple(meeple)
      end

      def corner_with_keep
        corner_with(:keep)
      end

      def corner_with_roost
        corner_with(:roost)
      end

      def ruins
        clearings
          .select { |_, clearing| clearing.includes_building?(:ruin) }
          .values
          .map(&:ruin)
      end

      def corner_with(type)
        corners.find do |corner|
          corner.tokens.any? { |tokens| tokens.type == type } ||
            corner.buildings.any? { |building| building.type == type }
        end
      end

      def keep_in_corner?
        !!corner_with_keep
      end

      def clearings_without_keep
        clearings.values.reject(&:keep?)
      end

      def clearing_across_from_keep
        clearings[DIAGANOLS[corner_with_keep.priority]]
      end

      def clearings_other_than(other_clearing)
        clearings.values.reject { |clearing| clearing == other_clearing }
      end

      def clearings_with(type)
        clearings.select do |_, clearing|
          clearing.includes_building?(type) || clearing.includes_token?(type)
        end.values
      end

      def clearings_with_meeples(type)
        clearings.values.select { |clearing| clearing.includes_meeple?(type) }
      end

      def clearings_with_rule(faction)
        clearings.values.select { |clearing| clearing.ruled_by?(faction) }
      end

      def clearings_with_fewest_pieces
        clearings.values.min_by(clearings.count) do |clearing|
          clearing.all_pieces.count
        end
      end
    end
  end
end
