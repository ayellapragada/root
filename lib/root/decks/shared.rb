# frozen_string_literal: true

module Root
  module Decks
    # The idea here is just for for exiles and partisans or others later
    class Shared < Base
      attr_reader :dominance

      # both kinds of decks will have a discard to interact with
      def generate_deck
        @dominance = Decks::Dominance.new
        list_of_cards!
        deck.shuffle!
      end

      def discard_card(card)
        if card.dominance?
          @dominance[card.suit] = { card: card, status: 'free' }
        else
          discard << card
        end
      end

      def dominance_for(suit)
        @dominance[suit]
      end

      def change_dominance(suit, status)
        @dominance[suit] = { card: nil, status: status }
      end
    end
  end
end
