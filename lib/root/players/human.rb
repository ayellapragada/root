# frozen_string_literal: true

require_relative './base'

module Root
  module Players
    # Handles user logic for this.
    class Human < Base
      # I hate it but w.e. I wanna see if it works.
      # Just for terminal
      # :nocov:
      def pick_option(options)
        puts 'Pick an Option'
        puts options
          .map
          .with_index { |option, i| "(#{i + 1}) #{option}" }
          .join(' | ')
        gets.chomp.to_i - 1
      end
      # :nocov:
    end
  end
end
