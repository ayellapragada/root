# frozen_string_literal: true

module Root
  module Factions
    # Interface for basic faction logic
    class Base
      SETUP_PRIORITY = 'ZZZ'

      attr_reader :hand, :victory_points

      def initialize(player)
        @player = player
        @hand = []
        @victory_points = 0

        handle_faction_token_setup
      end

      # This is where every faction gets their pieces into their hand.
      def handle_faction_token_setup; end

      def hand_size
        hand.size
      end

      def draw_card(deck)
        @hand << deck.draw_from_top
      end

      def setup_priority
        self.class::SETUP_PRIORITY
      end

      def setup(board:, player:); end
    end
  end
end
