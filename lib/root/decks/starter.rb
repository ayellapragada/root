# frozen_string_literal: true

require_relative '../cards/base'

module Root
  module Decks
    # This is the deck for crafting and ambushes and etc.
    # The idea here is just to leave room for exiles and partisans.
    class Starter < Base
      DECK_SIZE = 54

      # We're not currently interested in getting items done
      # Really just want to lay the foundation
      def generate_deck
        DECK_SIZE.times { deck << Cards::Item.new(suit: :fox) }
      end
    end
  end
end
