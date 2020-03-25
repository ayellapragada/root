# frozen_string_literal: true

require_relative './base'

module Root
  module Factions
    # Handle birds faction logic
    class Bird < Base
      SETUP_PRIORITY = 'B'

      attr_reader :viziers, :leaders, :used_leaders

      def faction_symbol
        :birds
      end

      def handle_faction_token_setup
        handle_meeple_setup
        handle_roost_setup
        handle_vizier_setup
        handle_leader_setup
      end

      def handle_meeple_setup
        @meeples = Array.new(20) { Pieces::Meeple.new(:bird) }
      end

      def handle_roost_setup
        @buildings = Array.new(7) { Birds::Roost.new }
      end

      def handle_vizier_setup
        @viziers = Array.new(2) { Cards::Base.new(suit: :bird) }
      end

      # GOING TO HALF ASS THIS FOR NOW TODO NEED 4 types
      # COME BACK TO THIS ONCE DECREE IS DONE
      def handle_leader_setup
        @leaders = Array.new(4) { Cards::Base.new(suit: :bird) }
        @used_leaders = []
      end

      def roosts
        @roosts ||= buildings.select { |b| b.type == :roost }
      end

      def setup(board:)
        if board.keep_in_corner?
          clearing = board.clearing_across_from_keep
        else
          options = board.available_corners
          choice = player.pick_option(options)
          clearing = options[choice]
        end
        board.create_building(roosts.pop, clearing)
        6.times { board.place_meeple(meeples.pop, clearing) }
      end
    end
  end
end
