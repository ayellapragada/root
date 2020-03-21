# frozen_string_literal: true

module Root
  # This is going to be handling input / output for different screens
  module Display
    # We currently (and probably will only ever) display to terminal.
    # This handles all of that sort of logic here.
    class Terminal
      #:nocov:
      def pick_option(options)
        display_pick_option_message
        display_options(options)
        ask_for_selected_option
      end

      private

      def display_pick_option_message
        puts 'Pick an Option'
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
