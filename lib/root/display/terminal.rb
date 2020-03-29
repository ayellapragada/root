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
        display_options(options)
        ask_for_selected_option
      end

      def render_game(game, _player_to_view_as)
        r = Root::Display::WoodlandsTerminal.new(game.board).display.join("\n")
        system('clear') || system('cls')
        puts(r)
      end

      private

      def display_pick_option_message(key)
        puts PROMPT_MESSAGES[key]
      end

      def display_options(options)
        puts format_options_with_numbers(options)
      end

      def format_options_with_numbers(options)
        options
          .map
          .with_index { |option, i| "(#{i + 1}) #{option}" }
          .join(' | ')
      end

      def ask_for_selected_option
        gets.chomp.to_i - 1
      end
      #:nocov:
    end
  end
end
