# frozen_string_literal: true

require 'rainbow'

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
        (1 + options.length).times { Cursor.clear_previous_line }
        puts 'Invalid Choice, try again'
        retry
      end

      def render_game(game, current_player, clearings)
        map = WoodlandsMap.new(game.board, clearings).display
        history = History.new(game.history).display
        current_info = Info.new(current_player, show_private: true).display
        other_info = Info.for_multiple(game.players.except_player(current_player))
        space_for_other_info = other_info.map { |str| str.gsub(/\e\[([;\d]+)?m/, '').length }.max

        # If needed, how to get the length of a board.
        # current_info.split("\n").length

        total_height = map.length + current_player.faction.hand.length

        merged = map.map.with_index do |i, idx|
          info = other_info[idx] || ' ' * space_for_other_info
          hist = history[idx] || '' # Default History / Empty Spaces
          i + '  ' + info + '  ' +  hist
        end

        current_row = Cursor.pos[:row]
        move_cursor_to_top

        merged.each { |row| puts row }
        clear_out_rest_of_screen(current_row, total_height)
        puts current_info
        render_hand(current_player)
      end

      def render_hand(player)
        hand = player.faction.hand
        puts 'Hand:'
        hand.each do |card|
          puts Rainbow(card.inspect).fg(Colors::SUIT_COLOR[card.suit])
        end
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
        puts_blank_space
        puts 'Use "?" for help and "discard" to check discard pile.'
        puts_blank_space
        puts Messages::LIST[key][:prompt]
      end

      def puts_blank_space
        puts ''
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
        menu_opts = %w[? discard screen_clear]
        loop do
          option = gets.chomp
          return option unless menu_opts.include?(option)

          handle_showing_menu(option)
          Cursor.clear_previous_line
        end
      end

      def handle_showing_menu(option)
        render_help if option == '?'
        render_discard if option == 'discard'
        system('clear') || system('cls') if option == 'screen_clear'
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
