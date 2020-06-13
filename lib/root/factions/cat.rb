# frozen_string_literal: true

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

      def post_initialize_from_db(record)
        super
        @recruited = record[:info][:recruited]
        @remaining_actions = record[:info][:remaining_actions]
      end

      def format_for_db
        super.merge(
          {
            info: {
              recruited: @recruited,
              remaining_actions: @remaining_actions,
              crafted: @crafted
            }
          }
        )
      end

      def handle_faction_token_setup
        @meeples = Array.new(25) { Pieces::Meeple.new(faction_symbol) }
        @buildings = [
          Array.new(6) { Cats::Recruiter.new },
          Array.new(6) { Cats::Sawmill.new },
          Array.new(6) { Cats::Workshop.new }
        ].flatten
        @tokens = [Cats::Keep.new] + Array.new(8) { Cats::Wood.new }
      end

      def handle_faction_info_setup
        @remaining_actions = 0
        @recruited = false
      end

      def setup
        build_keep
        build_initial_buildings while need_to_build_starting_buildings?
        place_initial_warriors
      end

      def get_setup_actions
        return build_keep unless keep.empty?
        return build_initial_buildings if need_to_build_starting_buildings?

        place_initial_warriors
        {}
      end

      def need_to_build_starting_buildings?
        !initial_building_choice_opts.empty?
      end

      def initial_building_choice_opts
        %i[recruiter sawmill workshop].select do |type|
          current_number_out(type).zero?
        end
      end

      def build_keep
        options = board.available_corners
        player.choose(:c_initial_keep, options, required: true) do |clearing|
          place_keep(clearing)
        end
      end

      def build_initial_buildings
        player.choose(:c_initial_building_choice, initial_building_choice_opts, required: true) do |buils|
          player_places_building(buils)
        end
      end

      def player_places_building(building)
        player.choose(
          :c_initial_building,
          initial_building_opts,
          info: { building: building.capitalize }
        ) do |clearing|
          piece = send(building.pluralize).first
          place_building(piece, clearing)
        end
      end

      def initial_building_opts
        keep_clearing = board.corner_with_keep
        [keep_clearing, *keep_clearing.adjacents].select(&:with_spaces?)
      end

      def place_initial_warriors
        clearing = board.clearing_across_from_keep
        board.clearings_other_than(clearing).each { |cl| place_meeple(cl) }
        update_game
      end

      def birdsong
        super
        @recruited = false

        do_with_birdsong_options(:place_wood) { place_wood_in_all_sawmills }
      end

      # a very very minimal version for now
      # without improvements
      def get_birdsong_options
        @recruited = false
        @remaining_actions = 3
        @crafted = false

        do_with_birdsong_options(:place_wood) { place_wood_in_all_sawmills }
      end

      def place_wood_in_all_sawmills
        sawmill_clearings = board.clearings_with(:sawmill)
        if wood.count > sawmill_clearings.count
          sawmill_clearings.each do |cl|
            cl.buildings_of_type(:sawmill).count.times do
              place_wood(cl)
            end
          end
        else
          sawmill_opts = []
          sawmill_clearings.each do |cl|
            cl.buildings_of_type(:sawmill).each { sawmill_opts << cl }
          end
          until wood.count.zero?
            player.choose(:c_overwork, sawmill_opts, required: true) do |cl|
              sawmill_opts.delete_first(cl)
              place_wood(cl)
            end
          end
        end
        update_game
      end

      def get_daylight_options
        @crafted = true if craft_with_specific_timing_options.empty?
        return craft_with_specific_timing unless @crafted
        return if daylight_options.empty? || remaining_actions.zero?

        player.choose(
          :f_pick_action,
          daylight_options,
          yield_anyway: true,
          info: { actions: "(#{@remaining_actions} actions remaining) " }
        ) do |action|
          # :nocov:
          case action
          when :battle then with_action { battle }
          when :march then with_action { march }
          when :build then with_action { build }
          when :recruit then with_action { recruit }
          when :overwork then with_action { overwork }
          when :discard_bird then discard_bird
          when ->(n) { DAYLIGHT_OPTIONS.include?(n) } then do_daylight_option(action)
          when :none then @remaining_actions = 0
          end
          # :nocov:
        end
      end

      def daylight
        super
        @remaining_actions = 3
        craft_with_specific_timing

        until daylight_options.empty? || remaining_actions.zero?
          player.choose(
            :f_pick_action,
            daylight_options,
            yield_anyway: true,
            info: { actions: "(#{@remaining_actions} actions remaining) " }
          ) do |action|
            # :nocov:
            case action
            when :battle then with_action { battle }
            when :march then with_action { march }
            when :build then with_action { build }
            when :recruit then with_action { recruit }
            when :overwork then with_action { overwork }
            when :discard_bird then discard_bird
            when ->(n) { DAYLIGHT_OPTIONS.include?(n) } then do_daylight_option(action)
            when :none then @remaining_actions = 0
            end
            # :nocov:
          end
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
        super
        draw_cards
      end

      def draw_bonuses
        DRAW_BONUSES[:recruiter][0...current_number_out(:recruiter)].sum
      end

      def daylight_options
        [].tap do |options|
          options << :battle if can_battle?
          options << :march if can_move?
          options << :build if can_build?
          options << :recruit if can_recruit?
          options << :overwork if can_overwork?
          options << :discard_bird if can_discard_bird?
          add_daylight_options(options)
        end
      end

      def build
        player.choose(:f_build_options, build_options) do |cl|
          build_in_clearing(cl)
        end
      end

      def build_in_clearing(clearing)
        accessible_wood = clearing.connected_wood
        options_for_building = %i[sawmill recruiter workshop].select do |type|
          !send(type.pluralize).count.zero? &&
            (accessible_wood.count >= cost_for_next_building(type))
        end

        player.choose(:f_pick_building, options_for_building) do |building_type|
          wood_to_remove = cost_for_next_building(building_type)
          piece = send(building_type.pluralize).first

          remove_wood(accessible_wood, wood_to_remove)
          return false if dry_run?

          gain_vps(vp_for_next(building_type))
          place_building(piece, clearing)
        end
      end

      VICTORY_POINTS = {
        sawmill: [0, 1, 2, 3, 4, 5],
        workshop: [0, 2, 2, 3, 4, 5],
        recruiter: [0, 1, 2, 3, 3, 4]
      }.freeze

      def remove_wood(accessible_wood, num_wood_to_remove)
        until num_wood_to_remove.zero?
          player.choose(:c_wood_removal, accessible_wood, required: true) do |clearing|
            accessible_wood.delete_first(clearing)
            tokens << clearing.remove_wood
            num_wood_to_remove -= 1
          end
        end
      end

      # If you make the first movement, you need to make the second
      # Else the first can be cancelled
      def march
        make_move(required: true) if make_move
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
        return if dry_run?

        @recruited = true
        recuitable_clearings = board.clearings_with(:recruiter)
        clearings_recruited_in = []

        if meeples.count > recuitable_clearings.count
          recuitable_clearings.each do |cl|
            clearings_recruited_in << cl
            cl.buildings_of_type(:recruiter).count.times do
              place_meeple(cl)
            end
          end
        else
          recruit_opts = []
          recuitable_clearings.each do |cl|
            cl.buildings_of_type(:recruiter).each { recruit_opts << cl }
          end
          until meeples.count.zero?
            player.choose(:c_recruit, recruit_opts, required: true) do |cl|
              recruit_opts.delete_first(cl)
              place_meeple(cl)
            end
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
        player.choose(:c_overwork, overwork_options, required: false) do |cl|
          discard_card_with_suit(cl.suit, required: false) do
            return if dry_run?

            place_wood(cl)
            player.add_to_history(:c_overwork, clearing: cl.priority)
            update_game
          end
        end
      end

      def discard_bird
        discard_card_with_suit(:bird, required: false) do
          return if dry_run?

          @remaining_actions += 1
          update_game
        end
      end

      def post_battle(battle)
        card_opts = cards_in_hand_with_suit(battle.clearing.suit)
        meeps = battle.pieces_removed.select { |p| p.meeple_of_type?(faction_symbol) }
        return if card_opts.empty? || meeps.empty? || !board.keep_in_corner?

        field_hospital(meeps, battle.clearing.suit)
      end

      def field_hospital(meeps, suit)
        opts = cards_in_hand_with_suit(suit)
        player.choose(:c_field_hospital, opts, info: { suit: suit, num: meeps.count }) do |card|
          discard_card(card)
          meeps.length.times do
            place_meeple(board.corner_with_keep)
          end
          player.add_to_history(:c_field_hospital, suit: suit, num: meeps.count)
        end
      end

      private

      def suits_to_craft_with
        clearings = board.clearings_with(:workshop)
        res = []
        clearings.each do |cl|
          cl.buildings_of_type(:workshop).count.times do
            res << cl.suit
          end
        end
        res
      end
    end
  end
end
