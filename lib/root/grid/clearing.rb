# frozen_string_literal: true

require_relative './ruin'

module Root
  module Grid
    # Node data structure for clearings
    class Clearing
      VALID_SUITS = %i[bunny mice rabbit].freeze

      attr_reader :priority, :suit, :slots, :ruin,
                  :adjacents, :buildings, :tokens, :meeples

      def initialize(priority:, suit:, slots:, ruin: false)
        @priority = priority
        @suit = suit
        @slots = slots
        create_spaces_for_pieces
        create_ruin if ruin
      end

      def create_spaces_for_pieces
        @adjacents = []
        @buildings = []
        @tokens = []
        @meeples = []
      end

      # :nocov:
      # This breaks sandi_meter :sweats:
      def inspect
        adjacents_nodes = adjacents.map(&:priority).join(', ')
        building_types = buildings.map(&:type).join(', ')
        token_types = tokens.map(&:type).join(', ')
        meeple_types = meeples.map(&:type).join(', ')

        result = [
          "Clearing ##{priority}: #{suit}",
          "Adjacents: #{adjacents_nodes}"
        ]

        result << "Buildings: #{building_types}" if buildings.any?
        result << "Tokens: #{token_types}" if tokens.any?
        result << "Meeples: #{meeple_types}" if meeples.any?

        result.join(' | ')
      end
      # :nocov:

      def ruin?
        !!ruin
      end

      def with_spaces?
        available_slots >= 1
      end

      def available_slots
        slots - buildings.count
      end

      def add_path(other_clearing)
        return if adjacents.include?(other_clearing)

        adjacents << other_clearing
        other_clearing.add_path(self)
      end

      # This needs to check for available slots
      def create_building(building)
        return unless with_spaces?

        buildings << building
      end

      def place_token(token)
        tokens << token
      end

      def place_meeple(meeple)
        meeples << meeple
      end

      def includes_building?(type)
        buildings.any? { |building| building.type == type }
      end

      private

      def create_ruin
        @ruin = Ruin.new
        @buildings << @ruin
      end
    end
  end
end
