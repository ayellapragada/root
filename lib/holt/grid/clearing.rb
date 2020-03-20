# frozen_string_literal: true

require_relative './ruin'

module Holt
  module Grid
    # Node data structure for clearings
    class Clearing
      VALID_SUITS = %i[bunny mice rabbit].freeze

      attr_reader :suit, :slots, :ruin

      def initialize(suit:, slots:, ruin: false)
        @suit = suit
        @slots = slots
        create_ruin if ruin
      end

      def ruin?
        !!ruin
      end

      def available_slots
        ruin ? (slots - 1) : slots
      end

      private

      def create_ruin
        @ruin = Ruin.new
      end
    end
  end
end
