# frozen_string_literal: true

require_relative './ruin'

module Root
  module Grid
    # Node data structure for clearings
    class Clearing
      VALID_SUITS = %i[bunny mice rabbit].freeze

      attr_reader :priority, :suit, :slots, :ruin, :adjacents, :buildings

      def initialize(priority:, suit:, slots:, ruin: false)
        @priority = priority
        @suit = suit
        @slots = slots
        @adjacents = []
        @buildings = []
        create_ruin if ruin
      end

      # :nocov:
      def inspect
        adjacents_nodes = adjacents.map(&:priority).join(', ')
        "Clearing ##{priority}: #{suit} | Adjacents: #{adjacents_nodes}"
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

      def create_building(building)
        buildings << building
      end

      private

      def create_ruin
        @ruin = Ruin.new
        @buildings << @ruin
      end
    end
  end
end
