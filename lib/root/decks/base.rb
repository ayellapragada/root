# frozen_string_literal: true

module Root
  module Decks
    # Just a base concept of a deck for things like the quest deck,
    # the shared deck, and then the potential Exiles and Partisans deck
    class Base
      include Enumerable

      attr_reader :deck

      def initialize
        @deck = []
        generate_deck
      end

      def draw_from_top(num = 1)
        deck.shift(num)
      end

      private

      def each
        deck.map { |card| yield card }
      end
    end
  end
end
