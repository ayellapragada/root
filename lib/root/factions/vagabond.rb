# frozen_string_literal: true

require_relative './base'

module Root
  module Factions
    # Handle vagabond faction logic
    class Vagabond < Base
      SETUP_PRIORITY = 'D'

      attr_reader :items, :teas, :coins, :bags, :character, :relationships

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

      def setup(board:, players:, characters:, **_)
        handle_character_select(characters)
        $GAME&.render
        handle_forest_select(board)
        $GAME&.render
        handle_ruins(board)
        handle_relationships(players)
        $GAME&.render
      end

      def handle_character_select(characters)
        choice = player.pick_option(:v_char_sel, characters)
        character = characters.remove_from_deck(characters[choice])
        @character = character
      end

      def handle_forest_select(board)
        options = board.forests.values
        choice = player.pick_option(:v_forest_sel, options)
        forest = options[choice]
        board.place_meeple(meeples.pop, forest)
      end

      def handle_ruins(board)
        starting_items = %i[bag boots hammer sword].shuffle
        board.ruins.each do |ruin|
          ruin.items << starting_items.pop
        end
      end

      def handle_relationships(players)
        others = players.except_player(player)
        @relationships = Vagabonds::Relationships.new(others)
      end
    end
  end
end
