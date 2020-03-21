# frozen_string_literal: true

require_relative './ruin'

module Root
  module Grid
    # Node data structure for clearings
    class Clearing
      VALID_SUITS = %i[bunny mice rabbit].freeze

      attr_reader :priority, :suit, :slots, :ruin,
                  :adjacents, :buildings, :tokens

      def initialize(priority:, suit:, slots:, ruin: false)
        @priority = priority
        @suit = suit
        @slots = slots
        @adjacents = []
        @buildings = []
        @tokens = []
        create_ruin if ruin
      end

      # :nocov:
      def inspect
        adjacents_nodes = adjacents.map(&:priority).join(', ')
        building_types = buildings.map(&:type).join(', ')
        token_types = tokens.map(&:type).join(', ')
        [
          "Clearing ##{priority}: #{suit}",
          "Adjacents: #{adjacents_nodes}",
          "Buildings: #{building_types}",
          "Tokens: #{token_types}"
        ].join(' | ')
      end
      # :nocov:

      def ruin?
        !!ruin
      end

      def with_spaces?
        available_slots >= 1
      end

      def available_slots
        ruin ? (slots - 1) : slots
      end

      def add_path(other_clearing)
        return if adjacents.include?(other_clearing)

        adjacents << other_clearing
        other_clearing.add_path(self)
      end

      # # This needs to check for available slots
      # def create_building(building)
      #   buildings << building
      # end

      def place_token(token)
        tokens << token
      end

      private

      def create_ruin
        @ruin = Ruin.new
        @buildings << @ruin
      end
    end
  end
end
