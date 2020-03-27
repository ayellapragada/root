# frozen_string_literal: true

require_relative './base'

module Root
  module Factions
    # Handle vagabond faction logic
    class Vagabond < Base
      SETUP_PRIORITY = 'D'

      attr_reader :items, :teas, :coins, :bags

      def faction_symbol
        :vagabond
      end

      def handle_faction_token_setup
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

      def setup(board:, quest:, players:, **_)
      end
    end
  end
end
