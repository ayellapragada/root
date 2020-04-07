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
        14.times { deck << Cards::Base.new(suit: :fox) }
        13.times { deck << Cards::Base.new(suit: :mouse) }
        13.times { deck << Cards::Base.new(suit: :bunny) }
        14.times { deck << Cards::Base.new(suit: :bird) }
        deck.shuffle!
      end
    end
  end
end
