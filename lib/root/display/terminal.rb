# frozen_string_literal: true

require_relative './woodlands_terminal'

module Root
  module Display
    # We currently (and probably will only ever) display to terminal.
    # This handles all of that sort of logic here.
    class Terminal
      class InputError < StandardError; end
      PROMPT_MESSAGES = {
        test_option: 'Test Option Woo!',
        v_char_sel: 'Pick a Vagabond to be your Character',
        v_forest_sel: 'Pick a Forest to start in',
        c_initial_keep: 'Pick where to place the Keep',
        c_initial_sawmill: 'Pick where to place first Sawmill',
        c_initial_workshop: 'Pick where to place first Workshop',
        c_initial_recruiter: 'Pick where to place first Recruiter',
        c_overwork: 'Pick a clearing to get an extra wood in',
        c_wood_removal: 'Pick clearings to remove wood from',
        f_item_selet: 'Pick an item to craft',
        f_discard_card: 'Pick a card to discard',
        f_build_options: 'Pick a clearing to build in',
        f_who_to_battle: 'Pick a faction to battle against',
        f_battle_options: 'Pick a clearing to battle in',
        f_pick_building: 'Pick a type of building to make',
        f_move_from_options: 'Pick a clearing to move from',
        f_move_to_options: 'Pick a clearing to move to',
        f_move_number: 'Pick a number of meeples to move',
        f_pick_action: 'Pick an action to take',
        b_new_leader: 'Pick the next leader',
        b_first_roost: 'Pick where to place the first Roost with 6 Warriors',
        b_card_for_decree: 'Pick card to place into decree',
        b_area_in_decree: 'Pick a area in decree to place card',
        b_comeback_roost: 'Pick where to place your new first Roost with 3 Warriors',
        b_recruit_clearing: 'Pick which clearing to recruit in'
      }.freeze

      # NOT TESTING TERMINAL BECAUSE OOFY
      #:nocov:
      def pick_option(key, options)
        display_pick_option_message(key)
        if options.first.is_a?(Grid::Clearing)
          display_clearing_options(options)
          get_and_map_choice_to_index(options)
        else
          display_options(options)
          input_for_options(options)
        end
      rescue Root::Display::Terminal::InputError
        puts 'oops'
        retry
      end

      def render_game(game, _player_to_view_as, clearings)
        game_map = Root::Display::WoodlandsTerminal.new(game.board, clearings).display
        history = Root::Display::HistoryTerminal.new(game.history).display

        merged = game_map.map.with_index do |i, idx|
          hist = history[idx] || '' # Default History / Empty Spaces
          i + hist
        end

        current = Cursor.pos

        puts "\e[0;0H"

        merged.each { |row| puts row }

        puts "\e[s"
        remaining = current[:row] - game_map.length
        remaining.times do
          puts "\e[0K"
        end
        puts "\e[u"
      end

      private

      def display_pick_option_message(key)
        puts PROMPT_MESSAGES[key]
      end

      def display_options(options)
        puts format_options_with_numbers(options)
      end

      def display_clearing_options(options)
        puts format_options_with_clearings(options)
      end

      def format_options_with_numbers(options)
        options
          .map
          .with_index { |option, i| "(#{i + 1}) #{option.inspect}" }
          .join("\n")
      end

      def format_options_with_clearings(options)
        options
          .map { |option| "(#{option.priority}) #{option.inspect}" }
          .join("\n")
      end

      def get_and_map_choice_to_index(options)
        priority = gets.chomp
        options.find_index do |o|
          o.priority == priority.to_i ||
            o.priority == priority.upcase.to_sym
        end.tap do |res|
          raise InputError unless res
        end
      end

      def input_for_options(options)
        (gets.chomp.to_i - 1).tap do |res|
          raise InputError if res <= -1 || res >= options.count
        end
      end
      #:nocov:
    end
  end
end
