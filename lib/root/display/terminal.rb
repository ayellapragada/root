# frozen_string_literal: true

require_relative './woodlands_terminal'

module Root
  # This is going to be handling input / output for different screens
  module Display
    # We currently (and probably will only ever) display to terminal.
    # This handles all of that sort of logic here.
    class Terminal
      PROMPT_MESSAGES = {
        test_option: 'Test Option Woo!',
        v_char_sel: 'Pick a Vagabond to be your Character',
        v_forest_sel: 'Pick a Forest to start in',
        c_initial_keep: 'Pick where to place the Keep',
        c_initial_sawmill: 'Pick where to place first Sawmill',
        c_initial_workshop: 'Pick where to place first Workshop',
        c_initial_recruiter: 'Pick where to place first Recruiter',
        f_item_selet: 'Pick an item to craft',
        b_new_leader: 'Pick the next leader',
        b_first_roost: 'Pick where to place the first Roost'
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
      rescue StandardError
        puts 'oops'
        retry
      end

      def render_game(game, _player_to_view_as, clearings)
        Root::Display::WoodlandsTerminal
          .new(game.board, clearings)
          .display
          .join("\n")
          .tap do |res|
          clear_screen
          puts(res)
        end
      end

      # EXPERIMENTAL! Lots to be tried and tested here
      def clear_screen
        system('clear') || system('cls')
        # print "\033[2J"
        # print "\033[0;0H"
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
          raise unless res
        end
      end

      def input_for_options(options)
        (gets.chomp.to_i - 1).tap do |res|
          raise if res <= -1 || res >= options.count
        end
      end
      #:nocov:
    end
  end
end
