# frozen_string_literal: true

require 'rainbow'

module Root
  module Display
    # Code for displaying the prompt, and getting input.
    class Input
      class InputError < StandardError; end
      class ShowMenu < StandardError; end

      attr_reader :key, :options, :discard, :info

      # :nocov:
      def initialize(key, options, discard:, info:)
        @key = key
        @options = options
        @discard = discard
        @info = info
      end

      def display_pick_option_message(error: false)
        str = Messages::LIST[key][:prompt] % info.values
        if error
          puts "(Invalid Choice, Try Again) #{str}"
        else
          puts str
        end
      end

      def handle_input
        if options.first.is_a?(Grid::Clearing)
          handle_with_clearings
        else
          handle_with_regular
        end
      rescue Root::Display::Input::InputError
        (1 + options.length).times { Cursor.clear_previous_line }
        display_pick_option_message(error: true)
        retry
      end

      def handle_with_clearings
        puts format_options_with_clearings
        receive_and_map_choice
      end

      def handle_with_regular
        puts format_options_with_numbers
        input_for_options
      end

      def format_options_with_numbers
        options
          .map
          .with_index do |option, i|
          format_with_none(option) do
            format_with_color("(#{i + 1}) #{option.inspect}", option)
          end
        end
          .join("\n")
      end

      def format_options_with_clearings
        options
          .map do |option|
          format_with_none(option) do
            cl_text = "(#{option.priority}) #{option.inspect}"
            format_with_color(cl_text, option)
          end
        end
          .join("\n")
      end

      def format_with_none(option)
        if option == :none
          '(0) :none'
        else
          yield
        end
      end

      def format_with_color(string, option)
        if option.respond_to?(:suit)
          Rainbow(string).fg(Colors::SUIT_COLOR[option.suit])
        else
          string
        end
      end

      def receive_and_map_choice
        option = handle_getting_input
        return options.length - 1 if handle_none?(option)

        options.find_index do |o|
          next if o == :none

          o.priority == option.to_i ||
            o.priority == option.upcase.to_sym
        end.tap do |res|
          raise InputError unless res
        end
      end

      def handle_none?(option)
        options.include?(:none) && option == '0'
      end

      def input_for_options
        option = handle_getting_input
        return options.length - 1 if handle_none?(option)

        (option.to_i - 1).tap do |res|
          raise InputError if res <= -1 || res >= options.count
        end
      end

      def handle_getting_input
        menu_opts = %w[? help discard clear]
        loop do
          option = gets.chomp
          Cursor.clear_previous_line
          return option unless menu_opts.include?(option)

          handle_showing_menu(option)
        end
      end

      def handle_showing_menu(option)
        help_opts = %w[? help]
        render_help if help_opts.include?(option)
        render_discard if option == 'discard'
        system('clear') || system('cls') if option == 'clear'
      end

      def render_help
        file = File.read(File.join(File.dirname(__FILE__), 'help.txt'))
        IO.popen('less', 'w') { |f| f.puts file }
      end

      def render_discard
        res = discard.empty? ? 'None' : @discard.map(&:inspect).join("\n")
        IO.popen('less', 'w') { |f| f.puts res }
      end
      # :nocov:
    end
  end
end
