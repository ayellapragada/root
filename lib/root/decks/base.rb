# frozen_string_literal: true

module Root
  module Decks
    # Just a base concept of a deck for things like the quest deck,
    # the shared deck, and then the potential Exiles and Partisans deck
    class Base
      include Enumerable

      attr_reader :deck, :discard

      def initialize
        @deck = []
        @discard = []
        generate_deck
      end

      def draw_from_top(num = 1)
        if num > count
          discard.shuffle
          deck.concat(discard)
          @discard = []
        end
        deck.shift(num)
      end

      def remove_from_deck(card)
        deck.delete(card)
      end

      def remove_from_discard(card)
        discard.delete(card)
        card
      end

      # Funnily enough, not used.
      # Characters and Qeests never get discarded
      # def discard_card(card)
      #   discard << card
      # end

      def size
        deck.size
      end

      private

      def each
        deck.map { |card| yield card }
      end
    end
  end
end
