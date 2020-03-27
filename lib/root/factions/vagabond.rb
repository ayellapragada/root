# frozen_string_literal: true

require_relative './base'

module Root
  module Factions
    # Handle vagabond faction logic
    class Vagabond < Base
      SETUP_PRIORITY = 'D'

      attr_reader :items, :teas, :coins, :bags, :character

      def faction_symbol
        :vagabond
      end

      def handle_faction_token_setup
        @meeples = [Pieces::Meeple.new(:vagabond)]
        handle_empty_item_setup
      end

      def handle_empty_item_setup
        @items = []
        @teas = []
        @coins = []
        @bags = []
      end

      def damaged_items
        items.select(&:damaged?)
      end

      def setup(board:, quest:, players:, characters:, **_)
        handle_character_select(characters)
        handle_forest_select(board)
      end

      def handle_character_select(characters)
        choice = player.pick_option(characters)
        character = characters.remove_from_deck(characters[choice])
        @character = character
      end

      def handle_forest_select(board)
        options = board.forests.values
        choice = player.pick_option(options)
        forest = options[choice]
        board.place_meeple(meeples.pop, forest)
      end
    end
  end
end
