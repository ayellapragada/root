# frozen_string_literal: true

require_relative './ruin'

module Holt
  module Grid
    # Node data structure for clearings
    class Clearing
      VALID_SUITS = %i[bunny mice rabbit].freeze

      attr_reader :priority, :suit, :slots, :ruin, :adjacent_clearings

      def initialize(priority:, suit:, slots:, ruin: false)
        @priority = priority
        @suit = suit
        @slots = slots
        @adjacent_clearings = []
        create_ruin if ruin
      end

      def ruin?
        !!ruin
      end

      def available_slots
        ruin ? (slots - 1) : slots
      end

      def add_path(other_clearing)
        return if adjacent_clearings.include?(other_clearing)

        adjacent_clearings << other_clearing
        other_clearing.add_path(self)
      end

      private

      def create_ruin
        @ruin = Ruin.new
      end
    end
  end
end
