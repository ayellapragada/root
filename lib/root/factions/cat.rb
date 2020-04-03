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
        @meeples = Array.new(25) { Pieces::Meeple.new(faction_symbol) }
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
          player_places_building(building)
        end
      end

      def place_building(building, clearing)
        buildings.delete(building)
        board.create_building(building, clearing)
      end

      def place_token(token, clearing)
        tokens.delete(token)
        board.place_token(token, clearing)
      end

      def player_places_building(building)
        options_for_building = find_initial_options
        key = "c_initial_#{building.type}".to_sym
        choice = player.pick_option(key, options_for_building)
        clearing = options_for_building[choice]
        place_building(building, clearing)
      end

      def find_initial_options
        keep_clearing = board.corner_with_keep
        [keep_clearing, *keep_clearing.adjacents].select(&:with_spaces?)
      end

      def place_initial_warriors
        clearing = board.clearing_across_from_keep
        board.clearings_other_than(clearing).each { |cl| place_meeple(cl) }
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
          when :battle then battle
          when :march then march
          when :build then build
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
        !build_options.empty?
      end

      def can_discard_bird?
        !cards_in_hand_with_suit(:bird).empty?
      end

      def battle_options
        board.clearings_with_meeples(faction_symbol).select do |clearing|
          clearing.includes_any_other_attackable_faction?(faction_symbol)
        end
      end

      def move_options
        possible_options = []
        board.clearings_with_meeples(faction_symbol).select do |clearing|
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

      DRAW_BONUSES = {
        sawmill: [0, 0, 0, 0, 0, 0],
        workshop: [0, 0, 0, 0, 0, 0],
        recruiter: [0, 0, 1, 0, 1, 0]
      }.freeze

      def evening(deck)
        num = DRAW_BONUSES[:recruiter][0...current_number_out(:recruiter)].sum
        (1 + num).times { draw_card(deck) }
      end

      def current_number_out(type)
        plural_form = "#{type}s".to_sym
        6 - send(plural_form).count
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

      def build
        build_opts = build_options
        build_opts_choice = player.pick_option(:f_build_options, build_opts)
        clearing_to_build_in = build_options[build_opts_choice]
        build_in_clearing(clearing_to_build_in)
      end

      def build_in_clearing(clearing)
        accessible_wood = clearing.connected_wood
        options_for_building = %i[sawmill recruiter workshop].select do |type|
          accessible_wood.count >= cost_for_next_building(type)
        end
        choice = player.pick_option(:f_pick_building, options_for_building)
        building_type = options_for_building[choice]

        wood_to_remove = cost_for_next_building(building_type)

        plural_form = "#{building_type}s".to_sym
        piece = send(plural_form).first

        self.victory_points += vp_for_next(building_type)
        place_building(piece, clearing)
        remove_wood(accessible_wood, wood_to_remove)
      end

      VICTORY_POINTS = {
        sawmill: [0, 1, 2, 3, 4, 5],
        workshop: [0, 2, 2, 3, 4, 5],
        recruiter: [0, 1, 2, 3, 3, 4]
      }.freeze


      def remove_wood(accessible_wood, num_wood_to_remove)
        until num_wood_to_remove.zero?
          choice = player.pick_option(:c_wood_removal, accessible_wood)
          clearing_to_remove_from = accessible_wood[choice]
          wood << clearing_to_remove_from.remove_wood
          num_wood_to_remove -= 1
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

      def build_options
        board
          .clearings_with_rule(faction_symbol)
          .select(&:with_spaces?)
          .select do |cl|
          %i[sawmill recruiter workshop].any? do |b_type|
            cl.connected_wood.count >= cost_for_next_building(b_type)
          end
        end
      end

      def cost_for_next_building(building)
        plural_form = "#{building}s".to_sym
        currently_not_built = send(plural_form).length
        COSTS[building][6 - currently_not_built]
      end

      def vp_for_next(building)
        plural_form = "#{building}s".to_sym
        currently_not_built = send(plural_form).length
        VICTORY_POINTS[building][6 - currently_not_built]
      end

      COSTS = {
        sawmill: [0, 1, 2, 3, 3, 4],
        workshop: [0, 1, 2, 3, 3, 4],
        recruiter: [0, 1, 2, 3, 3, 4]
      }.freeze

      def recruit
        @recruited = true
        board.clearings_with(:recruiter).each do |cl|
          cl.buildings_of_type(:recruiter).count.times do
            place_meeple(cl)
          end
        end
      end

      def place_meeple(clearing)
        board.place_meeple(meeples.pop, clearing)
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
          sawmill_clearing.buildings_of_type(:sawmill).count.times do
            place_wood(sawmill_clearing)
          end
        end
      end

      def place_wood(clearing)
        piece = wood.first
        place_token(piece, clearing)
      end

      private

      def suits_to_craft_with
        board.clearings_with(:workshop).map(&:suit)
      end
    end
  end
end
