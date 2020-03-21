# frozen_string_literal: true

require_relative './base'

module Root
  module Factions
    # Handle cats faction logic
    class Cat < Base
      SETUP_PRIORITY = 'A'

      def faction_symbol
        :cats
      end

      def setup(board:)
        build_keep(board, player)
      end

      def build_keep(board, player)
        options = board.available_corners
        choice = player.pick_option(options)
        clearing = options[choice]

        board.place_token(:keep, clearing)
      end
    end
  end
end
