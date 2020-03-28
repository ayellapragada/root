# frozen_string_literal: true

module Root
  module Factions
    # Interface for basic faction logic
    class Base
      SETUP_PRIORITY = 'ZZZ'

      attr_reader :hand, :victory_points, :player, :meeples, :buildings, :tokens

      def initialize(player)
        @player = player
        @hand = []
        @victory_points = 0
        set_base_pieces
        handle_faction_token_setup
      end

      def set_base_pieces
        @meeples = []
        @buildings = []
        @tokens = []
      end

      def hand_size
        hand.size
      end

      def draw_card(deck)
        @hand << deck.draw_from_top
      end

      def setup_priority
        self.class::SETUP_PRIORITY
      end

      def take_turn(board:, players:, deck:, active_quests: nil); end
    end
  end
end
