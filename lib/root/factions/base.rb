# frozen_string_literal: true

module Root
  module Factions
    # Interface for basic faction logic
    class Base
      SETUP_PRIORITY = 'ZZZ'

      attr_accessor :victory_points

      attr_reader :hand, :player, :meeples, :buildings, :tokens, :items
      attr_writer :board

      def initialize(player)
        @player = player
        @hand = []
        @victory_points = 0
        set_base_pieces
        handle_faction_token_setup
      end

      def board
        player.board
      end

      def set_base_pieces
        @meeples = []
        @buildings = []
        @tokens = []
        @items = []
      end

      def hand_size
        hand.size
      end

      def discard_hand
        @hand = []
      end

      def draw_card(deck)
        @hand.concat(deck.draw_from_top)
      end

      def setup_priority
        self.class::SETUP_PRIORITY
      end

      def take_turn(board:, players:, deck:, active_quests: nil); end

      def craft_items(deck)
        @crafted_suits = []
        until craftable_items.empty?
          options = craftable_items
          choice = player.pick_option(:f_item_select, options)
          item = options[choice]
          craft_item(item, deck)
        end
      end

      def craft_item(choice, deck)
        @crafted_suits.concat(choice.craft)
        board.items.delete(choice.item)
        deck.discard_card(choice)
        hand.delete(choice)
        self.victory_points += choice.vp
        items << choice.item
      end

      def craftable_items
        @crafted_suits ||= []
        usable_suits = suits_to_craft_with - @crafted_suits
        return [] if usable_suits.empty?

        craftable_cards_in_hand(usable_suits)
      end

      def craftable_cards_in_hand(suits)
        hand.select do |card|
          card.craftable? &&
            (card.craft - suits).empty? &&
            board.items.include?(card.item)
        end
      end
    end
  end
end
