# frozen_string_literal: true

require_relative './ruin'

module Holt
  module Grid
    # Node data structure for clearings
    class Clearing
      VALID_SUITS = %i[bunny mice rabbit].freeze

      attr_reader :priority, :suit, :slots, :ruin, :adjacents

      def initialize(priority:, suit:, slots:, ruin: false)
        @priority = priority
        @suit = suit
        @slots = slots
        @adjacents = []
        create_ruin if ruin
      end

      def inspect
        adjacents_nodes = adjacents.map(&:priority).join(', ')
        "Clearing ##{priority}: #{suit} | Adjacents: #{adjacents_nodes}"
      end

      def ruin?
        !!ruin
      end

      def available_slots
        ruin ? (slots - 1) : slots
      end

      def add_path(other_clearing)
        return if adjacents.include?(other_clearing)

        adjacents << other_clearing
        other_clearing.add_path(self)
      end

      private

      def create_ruin
        @ruin = Ruin.new
      end
    end
  end
end
