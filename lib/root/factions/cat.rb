# frozen_string_literal: true

require_relative './base'
require_relative '../pieces/meeple'

module Root
  module Factions
    # Handle cats faction logic
    class Cat < Base
      SETUP_PRIORITY = 'A'

      def faction_symbol
        :cats
      end

      def handle_faction_token_setup
        25.times { meeples << Pieces::Meeple.new(:cat) }
        6.times { buildings << Cats::Recruiter.new }
        6.times { buildings << Cats::Sawmill.new }
        6.times { buildings << Cats::Workshop.new }
        8.times { tokens << Cats::Wood.new }
        tokens << Cats::Keep.new
      end

      def recruiters
        @recruiters ||= buildings.select { |b| b.type == :recruiter }
      end

      def sawmills
        @sawmills ||= buildings.select { |b| b.type == :sawmill }
      end

      def workshops
        @workshops ||= buildings.select { |b| b.type == :workshop }
      end

      def wood
        @wood ||= tokens.select { |b| b.type == :wood }
      end

      def keep
        @keep ||= tokens.select { |b| b.type == :keep }
      end

      def setup(board:)
        build_keep(board, player)
      end

      def build_keep(board, player)
        options = board.available_corners
        choice = player.pick_option(options)
        clearing = options[choice]

        board.place_token(keep.pop, clearing)
      end
    end
  end
end
