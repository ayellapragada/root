# frozen_string_literal: true

module Root
  module Factions
    # Handle cats faction logic
    class Cat < Base
      SETUP_PRIORITY = 'A'

      attr_reader :remaining_actions

      def faction_symbol
        :cats
      end

      def handle_faction_token_setup
        handle_meeple_setup
        handle_building_setup
        handle_token_setup
        @remaining_actions = 0
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

      def setup(*)
        build_keep
        build_initial_buildings
        place_initial_warriors
      end

      def build_keep
        options = board.available_corners
        choice = player.pick_option(:c_initial_keep, options)
        clearing = options[choice]

        piece = tokens.delete(keep.pop)
        board.place_token(piece, clearing)
      end

      def build_initial_buildings
        [sawmills, recruiters, workshops].each do |buils|
          building = buils.first
          buildings.delete(building)
          player_places_building(building)
        end
      end

      def player_places_building(building)
        options_for_building = find_initial_options
        key = "c_initial_#{building.type}".to_sym
        choice = player.pick_option(key, options_for_building)
        clearing = options_for_building[choice]
        board.create_building(building, clearing)
      end

      def find_initial_options
        keep_clearing = board.corner_with_keep
        [keep_clearing, *keep_clearing.adjacents].select(&:with_spaces?)
      end

      def place_initial_warriors
        clearing = board.clearing_across_from_keep
        board.clearings_other_than(clearing).each do |cl|
          board.place_meeple(meeples.pop, cl)
        end
      end

      def take_turn(deck:, **_)
        @recruited = false
        birdsong
        daylight(deck)
        evening(deck)
      end

      def daylight(deck)
        craft_items(deck)
        @remaining_actions = 3
        until remaining_actions.zero?
          opts = currently_available_options
          choice = player.pick_option(:f_pick_action, opts)
          action = opts[choice]

          # STILL IN PROGRESS, NOT ACCURATE TO WHAT IS OR IS NOT TESTED
          # :nocov:
          case action
          when :recruit then recruit
          when :overwork then overwork(deck)
          when :discard_bird then discard_bird(deck)
          end
          # :nocov:
          @remaining_actions -= 1
        end
      end

      def can_battle?
        !battle_options.empty?
      end

      def battle_options
        board.clearings_with_meeples(:cat).select do |clearing|
          clearing.includes_any_other_attackable_faction?(:cat)
        end
      end

      def move_options
      end

      def evening(deck)
        draw_card(deck)
      end

      def currently_available_options
        %i[battle march build overwork].tap do |options|
          options << :discard_bird if hand.any? { |card| card.suit == :bird }
          options << :recruit unless @recruited
        end
      end

      def recruit
        @recruited = true
        board.clearings_with(:recruiter).each do |clearing|
          board.place_meeple(meeples.pop, clearing)
        end
      end

      def overwork(deck)
        valid_suits = hand.map(&:suit)
        options = board.clearings_with(:sawmill).select do |c|
          valid_suits.include?(c.suit)
        end
        return if options.empty?

        choice = player.pick_option(:c_overwork, options)
        sawmill_clearing = options[choice]
        discard_card_with_suit(sawmill_clearing.suit, deck)
        place_wood(sawmill_clearing)
      end

      def discard_bird(deck)
        discard_card_with_suit(:bird, deck)
        @remaining_actions += 1
      end

      def discard_card_with_suit(suit, deck)
        options = hand.select { |card| card.suit == suit }
        choice = player.pick_option(:f_discard_card, options)
        card = options[choice]
        deck.discard_card(card)
        hand.delete(card)
      end

      def birdsong
        board.clearings_with(:sawmill).each do |sawmill_clearing|
          place_wood(sawmill_clearing)
        end
      end

      def place_wood(clearing)
        piece = wood.first
        board.place_token(piece, clearing)
        tokens.delete(piece)
      end

      private

      def suits_to_craft_with
        board.clearings_with(:workshop).map(&:suit)
      end
    end
  end
end
