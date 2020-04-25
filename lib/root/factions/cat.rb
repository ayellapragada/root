# frozen_string_literal: true

require 'terminal-table'

require_relative '../factions/cats/catable'

module Root
  module Factions
    # Handle cats faction logic
    class Cat < Base
      include Factions::Cats::Catable

      BUILDINGS = 6
      SETUP_PRIORITY = 'A'

      attr_reader :remaining_actions

      attr_buildings :sawmill, :workshop, :recruiter
      attr_tokens :wood, :keep

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

      def board_title
        "The Keep | Field Hospital \n#{item_list_for_info}"
      end

      def special_info(_show_private)
        {
          board: {
            title: board_title,
            rows: board_special_info,
            headings: %w[Wood 0 1 2 3 3 4]
          }
        }
      end

      def board_special_info
        rows = []
        rows << format_with_victory_ponts_and_draw_bonuses(:sawmill)
        rows << format_with_victory_ponts_and_draw_bonuses(:workshop)
        rows << format_with_victory_ponts_and_draw_bonuses(:recruiter)
        rows
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

        place_keep(clearing)
      end

      def build_initial_buildings
        [sawmills, recruiters, workshops].each do |buils|
          building = buils.first
          player_places_building(building)
        end
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

      def take_turn(players:, **_)
        @recruited = false
        birdsong
        daylight(players)
        evening
      end

      def birdsong
        board.clearings_with(:sawmill).each do |sawmill_clearing|
          sawmill_clearing.buildings_of_type(:sawmill).count.times do
            place_wood(sawmill_clearing)
          end
        end
      end

      def daylight(players)
        craft_items
        @remaining_actions = 3
        until remaining_actions.zero?
          opts = currently_available_options + [:none]
          choice = player.pick_option(:f_pick_action, opts)
          action = opts[choice]

          # STILL IN PROGRESS, NOT ACCURATE TO WHAT IS OR IS NOT TESTED
          # :nocov:
          case action
          when :battle then with_action { battle(players) }
          when :march then with_action { march(players) }
          when :build then with_action { build }
          when :recruit then with_action { recruit }
          when :overwork then with_action { overwork }
          when :discard_bird then discard_bird
          when :none then return
          end
          # :nocov:
        end
      end

      def can_recruit?
        !@recruited &&
          !board.clearings_with(:recruiter).empty? &&
          !meeples.count.zero?
      end

      def can_overwork?
        !overwork_options.empty? && !wood.count.zero?
      end

      def can_build?
        !build_options.empty?
      end

      def can_discard_bird?
        !cards_in_hand_with_suit(:bird).empty?
      end

      DRAW_BONUSES = {
        sawmill: [0, 0, 0, 0, 0, 0],
        workshop: [0, 0, 0, 0, 0, 0],
        recruiter: [0, 0, 1, 0, 1, 0]
      }.freeze

      def evening
        draw_cards
      end

      def draw_bonuses
        DRAW_BONUSES[:recruiter][0...current_number_out(:recruiter)].sum
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

        piece = send(building_type.pluralize).first

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
          accessible_wood.delete_at(accessible_wood.index(clearing_to_remove_from))
          wood << clearing_to_remove_from.remove_wood
          num_wood_to_remove -= 1
        end
      end

      def march(players)
        2.times { make_move(players) }
      end

      def build_options(*)
        clearings_ruled_with_space
          .select do |cl|
          %i[sawmill recruiter workshop].any? do |b_type|
            cl.connected_wood.count >= cost_for_next_building(b_type)
          end
        end
      end

      def cost_for_next_building(building)
        currently_not_built = send(building.pluralize).length
        COSTS[building][6 - currently_not_built]
      end

      def vp_for_next(building)
        currently_not_built = send(building.pluralize).length
        VICTORY_POINTS[building][6 - currently_not_built]
      end

      COSTS = {
        sawmill: [0, 1, 2, 3, 3, 4],
        workshop: [0, 1, 2, 3, 3, 4],
        recruiter: [0, 1, 2, 3, 3, 4]
      }.freeze

      def recruit
        @recruited = true
        recuitable_clearings = board.clearings_with(:recruiter)
        recuitable_clearings.each do |cl|
          cl.buildings_of_type(:recruiter).count.times do
            place_meeple(cl)
          end
        end
        player.add_to_history(
          :c_recruit,
          clearings: recuitable_clearings.map(&:priority).join(', ')
        )
      end

      def overwork_options
        valid_suits = convert_needed_suits(hand.map(&:suit))
        board.clearings_with(:sawmill).select do |c|
          valid_suits.include?(c.suit)
        end
      end

      def overwork
        options = overwork_options
        choice = player.pick_option(:c_overwork, options)
        sawmill_clearing = options[choice]
        discard_card_with_suit(sawmill_clearing.suit)
        place_wood(sawmill_clearing)
        player.add_to_history(:c_overwork, clearing: sawmill_clearing.priority)
      end

      def discard_bird
        discard_card_with_suit(:bird)
        @remaining_actions += 1
      end

      def post_battle(battle)
        card_opts = cards_in_hand_with_suit(battle.clearing.suit)
        meeps = battle.pieces_removed.select { |p| p.meeple_of_type?(faction_symbol) }
        return if card_opts.empty? || meeps.empty? || !board.keep_in_corner?

        field_hospital(meeps, battle.clearing.suit)
      end

      def field_hospital(meeps, suit)
        opt = player.pick_option(:c_field_hospital, %i[yes no])
        return if opt == 1

        discard_card_with_suit(suit)
        meeps.length.times do
          place_meeple(board.corner_with_keep)
        end

        player.add_to_history(
          :c_field_hospital,
          suit: suit,
          num: meeps.count
        )
      end

      private

      def suits_to_craft_with
        board.clearings_with(:workshop).map(&:suit)
      end
    end
  end
end
