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
        @meeples = Array.new(25) { Pieces::Meeple.new(:cats) }
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
          # when :battle then battle
          when :march then march
          # when :build then build
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

      def can_move?
        !move_options.empty?
      end

      def can_recruit?
        !@recruited && !board.clearings_with(:recruiter).empty?
      end

      def can_overwork?
        !overwork_options.empty?
      end

      def can_build?
        false
      end

      def can_discard_bird?
        !cards_in_hand_with_suit(:bird).empty?
      end

      def battle_options
        board.clearings_with_meeples(:cats).select do |clearing|
          clearing.includes_any_other_attackable_faction?(:cats)
        end
      end

      def move_options
        possible_options = []
        board.clearings_with_meeples(:cats).select do |clearing|
          clearing.adjacents.each do |adj|
            next if possible_options.include?(clearing)

            possible_options << clearing if rule?(clearing) || rule?(adj)
          end
        end

        possible_options
      end

      def clearing_move_options(clearing)
        clearing.adjacents.select do |adj|
          rule?(clearing) || rule?(adj)
        end
      end

      def rule?(clearing)
        clearing.ruled_by == faction_symbol
      end

      def evening(deck)
        draw_card(deck)
      end

      def currently_available_options
        [].tap do |options|
          options << :battle if can_battle?
          options << :march if can_move?
          options << :build if can_build?
          options << :recruit if can_recruit?
          options << :overwork if can_overwork?
          options << :discard_bird if can_discard_bird?
        end
      end

      def march
        2.times do
          where_from_opts = move_options
          where_from_choice = player.pick_option(:f_move_from_options, where_from_opts)
          where_from = where_from_opts[where_from_choice]
          move(where_from)
        end
      end

      def move(clearing)
        where_to_opts = clearing_move_options(clearing)
        where_to_choice = player.pick_option(:f_move_to_options, where_to_opts)
        where_to = where_to_opts[where_to_choice]

        max_choice = clearing.meeples_of_type(faction_symbol).count
        how_many_opts = [*1.upto(max_choice)]
        how_many_choice = player.pick_option(:f_move_number, how_many_opts)
        how_many = how_many_opts[how_many_choice]

        how_many.times do
          piece = clearing.meeples_of_type(faction_symbol).first
          clearing.meeples.delete(piece)
          where_to.meeples << piece
        end
      end

      def recruit
        @recruited = true
        board.clearings_with(:recruiter).each do |clearing|
          board.place_meeple(meeples.pop, clearing)
        end
      end

      def overwork_options
        valid_suits = hand.map(&:suit)
        board.clearings_with(:sawmill).select do |c|
          valid_suits.include?(c.suit)
        end
      end

      def overwork(deck)
        options = overwork_options
        choice = player.pick_option(:c_overwork, options)
        sawmill_clearing = options[choice]
        discard_card_with_suit(sawmill_clearing.suit, deck)
        place_wood(sawmill_clearing)
      end

      def discard_bird(deck)
        discard_card_with_suit(:bird, deck)
        @remaining_actions += 1
      end

      def cards_in_hand_with_suit(suit)
        hand.select { |card| card.suit == suit }
      end

      def discard_card_with_suit(suit, deck)
        options = cards_in_hand_with_suit(suit)
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
