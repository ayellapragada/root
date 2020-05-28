# frozen_string_literal: true

module Root
  module Decks
    # The idea here is just for for exiles and partisans or others later
    class Shared < Base
      attr_reader :dominance, :discard, :lost_souls

      def initialize(deck: [], discard: [], lost_souls: [], dominance: [], skip_generate: false)
        super(deck: deck, skip_generate: skip_generate)
        @discard = discard || []
        @lost_souls = lost_souls || []
        @dominance = Decks::Dominance.new(dominance: [])
      end

      # both kinds of decks will have a discard to interact with
      def generate_deck
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
        @dominance[suit][:card]
      end

      def change_dominance(suit, status)
        @dominance[suit] = { card: nil, status: status }
      end

      def substitute_dominance
        deck
          .select(&:dominance?)
          .each { |c| deck.delete(c) }
        %i[bird fox rabbit mouse].each do |suit|
          deck << Cards::Base.new(suit: suit)
        end
      end
    end
  end
end
