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
          headings: %w[Dominance By],
          rows: rows,
          style: { width: 22 }
        )
      end

      # :nocov:
      def rows
        %i[fox bunny mouse bird].map do |suit|
          card = dominance.find { |d| d.suit == suit }
          if card
            [
              Rainbow(suit.capitalize).fg(Colors::SUIT_COLOR[suit]),
              Rainbow(card.faction.capitalize).fg(card.faction.display_color)
            ]
          else
            [
              Rainbow(suit.capitalize).fg(Colors::SUIT_COLOR[suit]),
              '-'
            ]
          end
        end
      end
      # :nocov:
    end
  end
end
