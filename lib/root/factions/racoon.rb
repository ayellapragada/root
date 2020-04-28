# frozen_string_literal: true

require_relative './base'
require_relative '../factions/racoons/racoonable'

module Root
  module Factions
    # Handle racoon faction logic
    class Racoon < Base
      include Factions::Racoons::Racoonable

      SETUP_PRIORITY = 'D'

      attr_reader :teas, :coins, :satchels, :character, :relationships

      def faction_symbol
        :racoon
      end

      def handle_faction_token_setup
        @meeples = [Pieces::Meeple.new(:racoon)]
        handle_empty_item_setup
      end

      def handle_empty_item_setup
        @teas = []
        @coins = []
        @satchels = []
      end

      def damaged_items
        items.select(&:damaged?)
      end

      def setup(players:, characters:)
        handle_character_select(characters)
        handle_forest_select
        handle_ruins
        handle_relationships(players)
      end

      def handle_character_select(characters)
        choice = player.pick_option(:v_char_sel, characters)
        character = characters.remove_from_deck(characters[choice])
        @character = character
      end

      def handle_forest_select
        options = board.forests.values
        choice = player.pick_option(:v_forest_sel, options)
        forest = options[choice]
        board.place_meeple(meeples.pop, forest)
      end

      def handle_ruins
        starting_items = %i[bag boots hammer sword].shuffle
        board.ruins.each do |ruin|
          ruin.items << starting_items.pop
        end
      end

      def handle_relationships(players)
        others = players.except_player(player)
        @relationships = Racoons::Relationships.new(others)
      end
    end
  end
end
