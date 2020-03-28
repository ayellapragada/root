# frozen_string_literal: true

module Root
  module Factions
    # Handle cats faction logic
    class Cat < Base
      SETUP_PRIORITY = 'A'

      def faction_symbol
        :cats
      end

      def handle_faction_token_setup
        handle_meeple_setup
        handle_building_setup
        handle_token_setup
      end

      def handle_meeple_setup
        @meeples = Array.new(25) { Pieces::Meeple.new(:cat) }
      end

      def handle_building_setup
        @buildings = [
          Array.new(6) { Cats::Recruiter.new },
          Array.new(6) { Cats::Sawmill.new },
          Array.new(6) { Cats::Workshop.new }
        ].flatten
      end

      def handle_token_setup
        @tokens = [Cats::Keep.new] + Array.new(8) { Cats::Wood.new }
      end

      def recruiters
        buildings.select { |b| b.type == :recruiter }
      end

      def sawmills
        buildings.select { |b| b.type == :sawmill }
      end

      def workshops
        buildings.select { |b| b.type == :workshop }
      end

      def wood
        tokens.select { |b| b.type == :wood }
      end

      def keep
        tokens.select { |b| b.type == :keep }
      end

      def setup(board:, **_)
        build_keep(board)
        build_initial_buildings(board)
        place_initial_warriors(board)
      end

      def build_keep(board)
        options = board.available_corners
        choice = player.pick_option(options)
        clearing = options[choice]

        piece = tokens.delete(keep.pop)
        board.place_token(piece, clearing)
      end

      def build_initial_buildings(board)
        [sawmills, recruiters, workshops].each do |buils|
          building = buils.first
          buildings.delete(building)
          player_places_building(building, board)
        end
      end

      def player_places_building(building, board)
        options_for_building = find_initial_options(board)
        choice = player.pick_option(options_for_building)
        clearing = options_for_building[choice]
        board.create_building(building, clearing)
      end

      def find_initial_options(board)
        keep_clearing = board.corner_with_keep
        [keep_clearing, *keep_clearing.adjacents].select(&:with_spaces?)
      end

      def place_initial_warriors(board)
        clearing = board.clearing_across_from_keep
        board.clearings_other_than(clearing).each do |cl|
          board.place_meeple(meeples.pop, cl)
        end
      end

      def take_turn(board:, deck:, **_)
        birdsong(board)
        evening(deck)
      end

      def birdsong(board)
        board.clearings_with(:sawmill).each do |sawmill_clearing|
          piece = wood.first
          board.place_token(piece, sawmill_clearing)
          tokens.delete(piece)
        end
      end

      def evening(deck)
        draw_card(deck)
      end
    end
  end
end
