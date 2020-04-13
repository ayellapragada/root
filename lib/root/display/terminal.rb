# frozen_string_literal: true

require_relative './woodlands_map'

module Root
  module Display
    # We currently (and probably will only ever) display to terminal.
    # This handles all of that sort of logic here.
    class Terminal
      class InputError < StandardError; end

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
        game_map = Root::Display::WoodlandsMap.new(game.board, clearings).display
        history = Root::Display::History.new(game.history).display

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
