# frozen_string_literal: true

require_relative '../cards/base'

module Root
  module Decks
    # This is the deck for crafting and ambushes and etc.
    # The idea here is just to leave room for exiles and partisans.
    class Starter
      include Enumerable

      attr_reader :deck

      def initialize
        @deck = []
        generate_deck
      end

      def draw_from_top(num = 1)
        deck.shift(num)
      end

      # We're not currently interested in getting items done
      # Really just want to lay the foundation
      def generate_deck
        54.times { deck << Cards::Item.new(suit: :fox) }
      end

      private

      def each
        deck.map { |card| yield card }
      end
    end
  end
end
