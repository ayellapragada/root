# frozen_string_literal: true

require 'rainbow'

module Root
  module Display
    # Handle logic for showing the victory points
    # Either stack, or all one square?
    # Some way to handle it so it's not shifting constantly.
    class Dominance
      attr_reader :dominance

      def initialize(dominance)
        @dominance = dominance
      end

      def display
        ::Terminal::Table.new(
          title: 'Dominance',
          rows: rows,
          style: { width: 22 }
        )
      end

      def rows
        dominance.map do |suit, dom|
          [
            Rainbow(suit.capitalize).fg(Colors::SUIT_COLOR[suit]),
            dom[:status]
          ]
        end
      end
    end
  end
end
