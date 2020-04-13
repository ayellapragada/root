# frozen_string_literal: true

require_relative './woodlands_map'

module Root
  module Display
    # We currently (and probably will only ever) display to terminal.
    # This handles all of that sort of logic here.
    class Terminal
      class InputError < StandardError; end
      class ShowMenu < StandardError; end

      # NOT TESTING TERMINAL BECAUSE OOFY
      #:nocov:
      def pick_option(key, options, discard:)
        @discard = discard
        display_pick_option_message(key)
        handle_input(options)
      end

      def handle_input(options)
        if options.first.is_a?(Grid::Clearing)
          display_clearing_options(options)
          get_and_map_choice_to_index(options)
        else
          display_options(options)
          input_for_options(options)
        end
      rescue Root::Display::Terminal::InputError
        (1 + options.length).times { clear_previous_line }
        puts 'Invalid Choice, try again'
        retry
      end

      def render_game(game, _player_to_view_as, clearings)
        map = Root::Display::WoodlandsMap.new(game.board, clearings).display
        history = Root::Display::History.new(game.history).display

        merged = map.map.with_index do |i, idx|
          hist = history[idx] || '' # Default History / Empty Spaces
          i + hist
        end

        current_row = Cursor.pos[:row]
        move_cursor_to_top
        merged.each { |row| puts row }
        clear_out_rest_of_screen(current_row, map.length)
      end

      def clear_out_rest_of_screen(current_row, total_rows)
        puts "\e[s"
        remaining = current_row - total_rows
        remaining.times do
          puts "\e[0K"
        end
        puts "\e[u"
      end

      def move_cursor_to_top
        puts "\e[0;0H"
      end

      private

      def display_pick_option_message(key)
        puts 'Use "?" for help and "discard" to check discard pile.'
        puts ''
        puts Messages::LIST[key][:prompt]
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
        option = handle_getting_input

        options.find_index do |o|
          o.priority == option.to_i ||
            o.priority == option.upcase.to_sym
        end.tap do |res|
          raise InputError unless res
        end
      end

      def input_for_options(options)
        option = handle_getting_input
        (option.to_i - 1).tap do |res|
          raise InputError if res <= -1 || res >= options.count
        end
      end

      def handle_getting_input
        menu_opts = %w[? discard]
        loop do
          option = gets.chomp
          return option unless menu_opts.include?(option)

          handle_showing_menu(option)
          clear_previous_line
        end
      end

      def clear_previous_line
        puts "\e[2A"
        puts "\e[0K"
        puts "\e[2A"
      end

      def handle_showing_menu(option)
        render_help if option == '?'
        render_discard if option == 'discard'
      end

      def render_help
        file = File.read(File.join(File.dirname(__FILE__), 'help.txt'))
        IO.popen('less', 'w') { |f| f.puts file }
      end

      def render_discard
        res = @discard.empty? ? 'None' : @discard.map(&:inspect).join("\n")
        IO.popen('less', 'w') { |f| f.puts res }
      end
      #:nocov:
    end
  end
end
